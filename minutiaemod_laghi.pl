/*
 * Titolo:       minutiae
 * Autore:       Aldo Franco Dragoni - Team Intelligenza Artificale
 * Creato:	 14 dicembre 2018
 * Linguaggio:	 SWI Prolog
 * Status:       1.0
 * Descrizione:  funzionalit� determinare le minuzie all'interno
 * di una impronta digitale
 */

:- [impronta].

vicino(X/Y,Xv/Yv) :-
	(   Xv is X + 1,
	    Yv is Y + 1
	;   Xv is X + 1,
	    Yv = Y
	;   Xv is X + 1,
	    Yv is Y - 1
	;   Xv = X,
	    Yv is Y + 1
	;   Xv = X,
	    Yv is Y - 1
	;   Xv is X - 1,
	    Yv is Y + 1
	;   Xv is X - 1,
	    Yv = Y
	;   Xv is X - 1,
	    Yv is Y - 1
	).


isolati(T) :-
	findall(t(X,Y),isolato(X,Y,_),Isolati),
	length(Isolati,T).

isolato(X,Y,Ref) :-
	a(X,Y,Ref),
	findall(v(X,Y),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),[]),
	send(Ref, colour, colour(green)).

terminazioni(T) :-
	findall(t(X,Y),terminazione(X,Y,_),Terminazioni),
	length(Terminazioni,T).


% predicato per individuare le terminazioni interne all'impronta
terminazione(X,Y,Ref) :-
	a(X,Y,Ref),
	findall(v(X,Y),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),Vicini),
        length(Vicini,1),
	findall(v(X,Y),terminazioni_esterne_dx(X,Y),Ter_dx),
	findall(v(X,Y),terminazioni_esterne_sx(X,Y),Ter_sx),
	length(Ter_dx,L_dx),
	L_dx>0,
	length(Ter_sx,L_sx),
	L_sx>0,
	send(Ref, colour, colour(green)),
	send(Ref, fill_pattern, colour(green)).

terminazioni_esterne_dx(X,Y) :-
            a(Xv,Y,_),
            Xv > X .

terminazioni_esterne_sx(X,Y) :-
	    a(Xv,Y,_),
            Xv < X .

trova_tratti(X1) :-
	findall(t(X,Y),(terminazione(X,Y,_),tratto(t(X,Y),[],0)),Tratti),
	length(Tratti,X),
	X1 is X/2.

tratto(t(X,Y),Tratti,Acc) :-
	Acc =< 10,
	a(X,Y,Ref),
	calcolo_vicini(t(X,Y),N),
	N < 3,
	vicino(X/Y,Xv/Yv),
	a(Xv,Yv,_),
        \+ member(t(Xv,Yv),Tratti),
	Acc1 is Acc +1,
	!,
	tratto(t(Xv,Yv),[t(X,Y)|Tratti],Acc1),
	send(Ref, colour, colour(green)),
	send(Ref, fill_pattern, colour(green)).


tratto(t(X,Y),_,_) :-
	a(X,Y,Ref),
	terminazione(X,Y,_),
	send(Ref, colour, colour(green)),
	send(Ref, fill_pattern, colour(green)).



calcolo_vicini(t(X,Y),N) :-
	findall(t(X,Y),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),L),
	length(L,N).

trova_vicini(t(X,Y),L) :-
	findall(t(Xv,Yv),(vicino(X/Y,Xv/Yv),a(Xv,Yv,_)),L).



tratto_di_2(A,B,C,D,Ref1,Ref2) :-
	terminazione(A,B,Ref1),
	terminazione(C,D,Ref2),
	vicino(A/B,C/D).

biforcazioni(T) :-
	findall(Bif, biforcazione(Bif), Biforcazioni),
	length(Biforcazioni,T).

biforcazione(Bif2) :-
	a(X,Y,Ref),
	bif(X,Y,Bif),
	append(Bif,[Ref],Bif2),
	%new(Colore,colour(red)),
        %send(Ref,colour,colour(red)),
	%send(Ref,colour(colour(red))),
	%send(Ref,fill_pattern(colour(red))),
	colora_lista(Bif2,colour(red)).

%pattern 1
bif(X,Y,Bif) :-
	%a(X,Y,Ref0),
	X1 is X-1,
	Y1 is Y-1,
	%X2 is X,
	%Y2 is Y-1,
	%\+ a(X2,Y2,_),
	a(X1,Y1,Ref1),
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref2),
	X8 is X,
	Y8 is Y+1,
	a(X8,Y8,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 2
bif(X,Y,Bif) :-
	%a(X,Y,Ref0),
	X2 is X,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref2),
	%X8 is X,
	%Y8 is Y+1,
	%\+ a(X8,Y8,_),
	X9 is X+1,
	Y9 is Y+1,
        a(X9,Y9,Ref3),
        Bif = [Ref1,Ref2,Ref3].

%pattern 3
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X4 is X-1,
	%Y4 is Y,
	%\+ a(X4,Y4,_),
	X6 is X+1,
	Y6 is Y,
	a(X6,Y6,Ref2),
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 4
bif(X,Y,Bif) :-
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref1),
	X4 is X-1,
	Y4 is Y,
	a(X4,Y4,Ref2),
	%X6 is X+1,
	%Y6 is Y,
	%\+ a(X6,Y6,_),
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 5 pixel_riferimento=4
bif(X,Y,Bif) :-
	%X1 is X,
	%Y1 is Y-1,
	X2 is X+1,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	%X3 is X+2,
	%Y3 is Y-1,
	%X4 is X,
	%Y4 is Y,
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
	X6 is X+2,
	Y6 is Y,
	a(X6,Y6,Ref2),
	%X7 is X,
	%Y7 is Y-1,
	%X8 is X+1,
	%Y8 is Y+1,
	%X9 is X+2,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 6 riferimento_pixel=4
bif(X,Y,Bif) :-
	%X1 is X,
	%Y1 is Y-1,
	%X2 is X+1,
	%Y2 is Y-1,
	%X3 is X+2,
	%Y3 is Y-1,
	%X4 is X,
	%Y4 is Y,
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
	X6 is X+2,
	Y6 is Y,
	a(X6,Y6,Ref1),
	%X7 is X,
	%Y7 is Y-1,
	X8 is X+1,
	a(X8,Y8,Ref2),
	Y8 is Y+1,
	%X9 is X+2,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 7 riferimenti_pixel=4
bif(X,Y,Bif) :-
	%X1 is X,
	%Y1 is Y-1,
	X2 is X+1,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	%X3 is X+2,
	%Y3 is Y-1,
	%X4 is X,
	%Y4 is Y,
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
	%X6 is X+2,
	%Y6 is Y,
	%X7 is X,
	%Y7 is Y-1,
	X8 is X+1,
	Y8 is Y+1,
	a(X8,Y8,Ref2),
	%X9 is X+2,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 8 riferimenti_pixel=6
bif(X,Y,Bif) :-
	%X1 is X-2,
	%Y1 is Y-1,
	X2 is X-1,
	Y2 is Y-1,
	a(X2,Y2,Ref1),
	%X3 is X,
	%Y3 is Y-1,
	%X4 is X-2,
	%Y4 is Y,
	X5 is X+1,
	Y5 is Y,
	\+ a(X5,Y5,_),
	%X6 is X,
	%Y6 is Y,
	%X7 is X-2,
	%Y7 is Y+1,
	X8 is X-1,
	Y8 is Y+1,
	a(X8,Y8,Ref2),
	%X9 is X,
	%Y9 is Y+1,
	Bif = [Ref1,Ref2].

%pattern 9
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X2 is X,
	%Y2 is Y-1,
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref2),
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref3),
	%X8 is X,
	%Y8 is Y+1,
	%X9 is X+1,
	%Y9 is Y+1,
        Bif = [Ref1,Ref2,Ref3].

%pattern 10
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X2 is X,
	%Y2 is Y-1,
	%X3 is X+1,
	%Y3 is Y-1,
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref2),
	%X8 is X,
	%Y8 is Y+1,
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 11
bif(X,Y,Bif) :-
	X1 is X-1,
	Y1 is Y-1,
	a(X1,Y1,Ref1),
	%X2 is X,
	%Y2 is Y-1,
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref2),
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	%X7 is X-1,
	%Y7 is Y+1,
	%X8 is X,
	%Y8 is Y+1,
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern 12
bif(X,Y,Bif) :-
	%X1 is X-1,
	%Y1 is Y-1,
	%X2 is X,
	%Y2 is Y-1,
	X3 is X+1,
	Y3 is Y-1,
	a(X3,Y3,Ref1),
	%X4 is X-1,
	%Y4 is Y,
	%X6 is X+1,
	%Y6 is Y,
	X7 is X-1,
	Y7 is Y+1,
	a(X7,Y7,Ref2),
	%X8 is X,
	%Y8 is Y+1,
	X9 is X+1,
	Y9 is Y+1,
	a(X9,Y9,Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern13, riferimento X2-Y2
bif(X, Y, Bif):-
	X4 is X-1,
	Y4 is Y+1,
	X6 is X+1,
	Y6 is Y+1,
	X7 is X-1,
	Y7 is Y+2,
	a(X4, Y4, Ref1),
	a(X6, Y6, Ref2),
	a(X7, Y7, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern14, riferimento X2-Y2
bif(X, Y, Bif):-
	X4 is X-1,
	Y4 is Y+1,
	X6 is X+1,
	Y6 is Y+1,
	X9 is X+1,
	Y9 is Y+2,
	a(X4, Y4, Ref1),
	a(X6, Y6, Ref2),
	a(X9, Y9, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern15, riferimento X8-Y8
bif(X, Y, Bif):-
	X1 is X-1,
	Y1 is Y-2,
	X4 is X-1,
	Y4 is Y-1,
	X6 is X+1,
	Y6 is Y-1,
	a(X1, Y1, Ref1),
	a(X4, Y4, Ref2),
	a(X6, Y6, Ref3),
	Bif = [Ref1,Ref2,Ref3].
%pattern16, riferimento X8-Y8
bif(X, Y, Bif):-
	X3 is X+1,
	Y3 is Y-2,
	X4 is X-1,
	Y4 is Y-1,
	X6 is X+1,
	Y6 is Y-1,
	a(X3, Y3, Ref1),
	a(X4, Y4, Ref2),
	a(X6, Y6, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern17
bif(X, Y, Bif):-
    X3 is X+1,
    Y3 is Y-1,
    a(X3,Y3, Ref1),
    X4 is X-1,
    Y4 is Y,
    a(X4,Y4,Ref2),
    X8 is X,
    Y8 is Y+1,
    a(X8,Y8,Ref3),
    Bif = [Ref1,Ref2,Ref3].

%pattern18
bif(X, Y, Bif):-
    X2 is X,
    Y2 is Y-1,
    a(X2,Y2,Ref1),
    X6 is X+1,
    Y6 is Y,
    a(X6,Y6,Ref2),
    X7 is X-1,
    Y7 is Y+1,
    a(X7,Y7,Ref3),
    Bif = [Ref1,Ref2,Ref3].

%pattern19
bif(X, Y, Bif):-
    X2 is X,
    Y2 is Y-1,
    a(X2,Y2,Ref1),
    X4 is X-1,
    Y4 is Y,
    a(X4,Y4,Ref2),
    X9 is X+1,
    Y9 is Y+1,
    a(X9,Y9,Ref3),
    Bif = [Ref1,Ref2,Ref3].

%pattern20
bif(X, Y, Bif):-
    X1 is X-1,
    Y1 is Y-1,
    a(X1,Y1,Ref1),
    X6 is X+1,
    Y6 is Y,
    a(X6,Y6,Ref2),
    X8 is X,
    Y8 is Y+1,
    a(X8,Y8,Ref3),
    Bif = [Ref1,Ref2,Ref3].


%pattern21, riferimento X2-Y2
bif(X, Y, Bif):-
 /* coordinate:
        X1 is X-1,
	Y1 is Y,
	X3 is X+1,
	Y3 is Y,
	X4 is X-1,
	Y4 is Y+1,
	X5 is X,
	Y5 is Y+1,
	X6 is X+1,
	Y6 is Y+1,
	X7 is X-1,
	Y7 is Y+2,
	X8 is X,
	Y8 is Y+2,
	X9 is X+1,
	Y9 is Y+2 */
	X6 is X+1,
	Y6 is Y+1,
	X7 is X-1,
	Y7 is Y+2,
	X8 is X,
	Y8 is Y+2,
	a(X6, Y6, Ref1),
	a(X7, Y7, Ref2),
	a(X8, Y8, Ref3),
	Bif = [Ref1,Ref2,Ref3].


%pattern22, riferimento X2-Y2
bif(X, Y, Bif):-
	X1 is X-1,
	Y1 is Y,
	X6 is X+1,
	Y6 is Y+1,
	X8 is X,
	Y8 is Y+2,
	a(X1, Y1, Ref1),
	a(X6, Y6, Ref2),
	a(X8, Y8, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern23, riferimento X2-Y2
bif(X, Y, Bif):-
	X3 is X+1,
	Y3 is Y,
	X4 is X-1,
	Y4 is Y+1,
	X8 is X,
	Y8 is Y+2,
	a(X3, Y3, Ref1),
	a(X4, Y4, Ref2),
	a(X8, Y8, Ref3),
	Bif = [Ref1,Ref2,Ref3].

%pattern24, riferimento X2-Y2
bif(X, Y, Bif):-
	X4 is X-1,
	Y4 is Y+1,
	X8 is X,
	Y8 is Y+2,
	X9 is X+1,
	Y9 is Y+2,
	a(X4, Y4, Ref1),
	a(X8, Y8, Ref2),
	a(X9, Y9, Ref3),
	Bif = [Ref1,Ref2,Ref3].

laghi(T) :-
	findall(t(X,Y),(a(X,Y,_),calcolo_vicini(t(X,Y),N),N=3),Partenze),
	findall(t(X,Y),screma_partenze(Partenze,[],_),Part),
	writeln(Part),
	setof(t(X,Y),(member(t(X,Y),Part), lago(t(X,Y),[],0)), Laghi),
        length(Laghi,T).

screma_partenze([],L,L).
%screma_partenze([t(X,Y)],[t(X,Y)]).
screma_partenze([t(X,Y)|C],L,L1):-
	trova_vicini(t(X,Y),Vicini),
	controlla_presenze(Vicini,L),
	%append(L,[t(X,Y)],L1),
	screma_partenze(C,[t(X,Y)|L],L1).

screma_partenze([t(_,_)|C],L,L1):-
	screma_partenze(C,L,L1).

controlla_presenze([],_).
controlla_presenze([t(X,Y)|C],L):-
	a(X,Y,_),
	\+member(t(X,Y),L),



	controlla_presenze(C,L).


lago(t(X,Y),Semi_laghi,Acc) :-
	Acc >5,
	a(X,Y,_),
	vicino(X/Y,Xv/Yv),
	a(Xv,Yv,_),
	reverse(Semi_laghi,Inversa),
	head(Inversa,t(Xt,Yt)),
	trova_vicini(t(Xt,Yt),Vicini_testa),
	member(t(Xv,Yv),Vicini_testa),
        colora_lista_2(Semi_laghi,colour(red)),
	true.


lago(t(X,Y),Semi_laghi,Acc) :-
	Acc =< 300,
	a(X,Y,_),
	vicino(X/Y,Xv/Yv),
	a(Xv,Yv,_),
	\+ member(t(Xv,Yv),Semi_laghi),
	Acc1 is Acc +1,
	lago(t(Xv,Yv),[t(X,Y)|Semi_laghi],Acc1).

head([H|_],H).





%#######False minutiae##############�

false_minutiae(T,B):-
	trova_minutiae_biforc_term,
	trova_minutiae_biforcazioni,
	trova_minutiae_terminazioni,
	terminazioni(T),
	biforcazioni(B).

%false minutiae
% innanzitutto ho bisogno di un predicato che calcoli la distanza tra
% due minutie qualsiasi(due biforcazioni, due terminazioni, una bif
% una terminazione).
distanza_minutiae(Xa/Ya,Xb/Yb,Distanza):-
	Xdiff is Xb-Xa,
	Ydiff is Yb-Ya,
	XQ is Xdiff^2,
	YQ is Ydiff^2,
	Dist is XQ+YQ,
	Distanza is sqrt(Dist).

% di seguito mi occorre calcolare la distanza media tra due creste D,
% che si ottiene riga per riga:
% 1-scannerizzando la riga e sommando tutti i pixel il cui valore �
% 1(neri)
% 2- Divido la lunghezza della riga per la somma ottenuta, il risultato
% sar� D per quella riga.
% 3- Ripeto procedimento per tutte le righe e faccio la media per
% ottenere la distanza media tra due creste D(average inter-rigde
% width).
%
% Per ora metto D=6
trova_minutiae_terminazioni :-
	findall(t(X,Y),trova_false_terminazioni(t(X,Y),t(_,_)),_).

trova_false_terminazioni(t(X1,Y1),t(X2,Y2)):-
	terminazione(X1,Y1,_),
	terminazione(X2,Y2,_),
	X1\=X2,
	Y1\=Y2,
	distanza_minutiae(X1/Y1,X2/Y2,Distanza),
	Distanza =<6,
	retract(a(X1,Y2,_)),
	retract(a(X2,Y2,_)).

%facciamo stessa cosa per due biforcazioni
trova_minutiae_biforcazioni :-
	findall(t(X,Y,Bif),trova_false_biforcazioni(t(X,Y,Bif),t(_,_,_)),_).

trova_false_biforcazioni(t(X1,Y1,Bif),t(X2,Y2,Bif2)):-
	biforcazionecoordinate(X1,Y1,Bif),
	biforcazionecoordinate(X2,Y2,Bif2),
	X1\=X2,
	Y1\=Y2,
	Bif\=Bif2,
	distanza_minutiae(X1/Y1,X2/Y2,Distanza),
	Distanza=<6,
	retract(a(X1,Y1,_)),
	retract(a(X2,Y2,_)).

%facciamo stessa cosa per una biforcazione e una terminazione
trova_minutiae_biforc_term :-
	findall(t(X,Y,Bif),trova_false_bt(t(X,Y,Bif),t(_,_)),_).

trova_false_bt(t(X1,Y1,Bif),t(X2,Y2)):-
	biforcazionecoordinate(X1,Y1,Bif),
	terminazione(X2,Y2,_),
	X1\=X2,
	Y1\=Y2,
	distanza_minutiae(X1/Y1,X2/Y2,Distanza),
	Distanza=<6,
	retract(a(X1,Y1,_)),
	retract(a(X2,Y2,_)).

biforcazionecoordinate(X,Y,Bif) :-
	a(X,Y,_),
	bif(X,Y,Bif).























