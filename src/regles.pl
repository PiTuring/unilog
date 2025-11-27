% regles.pl ----------------------------------------------------------------------------------------

% Prédicat d'association des règles aux expressions

% regle(E, R) : associe à chaque expression E la règle R à appliquer
%               où E est une expression de la forme X ?= T 
%               et R est le nom de la règle à appliquer
% Règle trivial :
regle(X ?= T, trivial) :-
    X == T, !. % si les deux côtés sont identiques, on applique la règle trivial

% Règle CLASH (F1 et F2 sont des termes composés avec des symboles de fonction ou d'arité différentes) :
regle(F1 ?= F2, clash) :-
    compound(F1), % F1 est un terme composé
    compound(F2), % F2 est un terme composé
    (   functor(F1, F1n, N1), % extraction du symbole de fonction F1n et de l'arité N1 de F1
        functor(F2, F2n, N2), % extraction du symbole de fonction F2n et de l'arité N2 de F2
        (F1n \== F2n ; N1 \== N2) % F1n et F2n sont différents ou N1 et N2 sont différents
    ),
    !.

% Règle CHECK (X est une variable apparaissant dans T) :
regle(X ?= T, check) :-
    var(X), % X est une variable
    occur_check(X, T), % recherche de X dans T
    X \== T, % par définition, X ne peut pas être égal à T
    !.

% Règle RENAME (X et T sont des variables distinctes) :
regle(X ?= T, rename) :-
    var(X), % X est une variable
    var(T), % T est une variable
    X \== T, % X et T sont distinctes
    !.

% Règle SIMPLIFY (T est une constante) :
regle(X ?= T, simplify) :-
    var(X), % X est une variable
    atomic(T), % T est une constante
    !.

% Règle ORIENT (X est une variable et T n'est pas une variable) :
regle(T ?= X, orient) :-
    nonvar(T), % T n'est pas une variable
    var(X), % X est une variable
    !.

% Règle DECOMPOSE (F1 et F2 sont des termes composés avec le même symbole de fonction et de même arité) :
regle(F1 ?= F2, decompose) :-
    compound(F1), % F1 est un terme composé
    compound(F2), % F2 est un terme composé
    functor(F1, F, N), % extraction du symbole de fonction F et de l'arité N de F1
    functor(F2, F, N), % F2 a le même symbole de fonction F et la même arité N
    !.

% Règle EXPAND (X est une variable et T est un terme composé, X n'apparaît pas dans T) :
regle(X ?= T, expand) :-
    var(X), % X est une variable
    compound(T), % T est un terme composé
    \+ occur_check(X, T), % recherche de X dans T doit échouer
    !.

% ----------------------------------------------------------------------------------------------------------------

% occur_check(V, T) : vérifie si la variable V apparaît dans le terme T
occur_check(V, T) :-
    V == T, !.  % si V est égal à T, la recherche réussit

occur_check(_, T) :-
    atomic(T), !, fail. % si T est une constante, la recherche échoue

occur_check(V, T) :-
    compound(T), % T est un terme composé
    T =.. [_|Args], % décomposition de T en sa liste d'arguments Args
    member(Arg, Args), % parcours des arguments
    occur_check(V, Arg), !. % recherche récursive dans chaque argument


% ----------------------------------------------------------------------------------------------------------------

% reduit(R, E, P, Q) : transforme le système d'équations P en le système d'équations Q par application
%                      de la règle de transformation R à l'équation E.
%                      où R est le nom de la règle appliquée
%                      E est une équation de la forme X ?= T
%                      P est une paire (ListeEquations, Substitution)
%                      Q est une paire (NouvelleListeEquations, NouvelleSubstitution)
% Pour RENAME, SIMPLIFY et EXPAND, on applique la substitution {X/T} à P et S :
reduit(R, X ?= T, (P,S), (P2,S2)) :-
    member(R, [rename, simplify, expand]), % R est l'une des règles RENAME, SIMPLIFY ou EXPAND
    substitution(P, X, T, P1), % application de la substitution à P
    substitution(S, X, T, S1), % application de la substitution à S
    P2 = P1, % mise à jour de P2
    S2 = [X = T | S1]. % mise à jour de S2 avec la nouvelle substitution

% Pour ORIENT, on inverse l'expression E et on ne modifie pas P et S :
reduit(orient, T ?= X, (P,S), ([X ?= T|P],S)).  

% Pour DECOMPOSE, on décompose F1 ?= F2 en leurs arguments respectifs :
reduit(decompose, F1 ?= F2, (P,S), (P2, S)) :-
    F1 =.. [_|Args1], % extraction des arguments de F1
    F2 =.. [_|Args2], % extraction des arguments de F2
    pairs(Args1, Args2, NouvellesEquations), % création des nouvelles équations
    append(NouvellesEquations, P, P2). % mise à jour de P2 avec les nouvelles équations

% Pour CLASH et CHECK, on échoue en produisant echec :
reduit(clash, _, _, echec).
reduit(check, _, _, echec).

reduit(trivial, _, (P,S), (P,S)). % pour trivial, on ne modifie rien

% substitution(Equations, X, T, NouvellesEquations) : applique la substitution {X/T} à une liste d'équations
%                                                     Equations et retourne la nouvelle liste NouvellesEquations
%                                                     où Equations est une liste d'équations de la forme S ?= T0 ou d'assignations de la forme V = R
%                                                     X est une variable
%                                                     T est un terme
%                                                     NouvellesEquations est la liste résultante après application de la substitution
substitution([], _, _, []). % si la liste est vide, le résultat est une liste vide

substitution([A|Q], X, T, [A2|Q2]) :-
    (   A = (L ?= R) % si l'élément est une équation du type S ?= T0
    ->  substitution_equation(L ?= R, X, T, A2) % application de la substitution à l'équation
    ;   
        A = (V = R), % sinon, si l'élément est une substitution stockée sous la forme V = R
        substitution_terme(R, X, T, R2), % application de la substitution à R
        A2 = (V = R2) % reconstruction de l'assignation avec le nouveau terme
    ),
    substitution(Q, X, T, Q2). % récursion sur le reste de la liste

% substitution_equation(E, X, T, E2) : applique la substitution {X/T} à une équation E, même idée que pour substitution/4
substitution_equation(S ?= T0, X, T, S2 ?= T2) :-
    substitution_terme(S, X, T, S2), % application de la substitution à S
    substitution_terme(T0, X, T, T2). % application de la substitution à T0

% substitution_terme(Terme, X, T, Terme2) : applique la substitution {X/T} à un terme Terme, même idée que pour substitution/4
substitution_terme(Terme, X, T, T) :- 
    Terme == X, !. % si Terme est la variable X, on le remplace par T

substitution_terme(Terme, _, _, Terme) :-
    var(Terme), !. % si Terme est une autre variable, on la laisse inchangée

substitution_terme(Terme, _, _, Terme) :- 
    atomic(Terme), !. % si Terme est une constante, on le laisse inchangé

substitution_terme(Terme, X, T, Terme2) :-
    compound(Terme), % Terme est un terme composé
    Terme =.. [F|Args], % décomposition de Terme en son symbole de fonction F et ses arguments Args
    substitution_liste(Args, X, T, Args2), % application de la substitution à chaque argument
    Terme2 =.. [F|Args2]. % reconstruction du terme avec les nouveaux arguments

% substitution_liste(Liste, X, T, NouvelleListe) : applique la substitution {X/T} à chaque élément de Liste, même idée que pour substitution/4
substitution_liste([], _, _, []). % si la liste est vide, le résultat est une liste vide

substitution_liste([A|Q], X, T, [A2|Q2]) :-
    substitution_terme(A, X, T, A2), % application de la substitution à l'élément A
    substitution_liste(Q, X, T, Q2). % récursion sur le reste de la liste

% pairs(L1, L2, Equations) : transforme deux listes d’arguments en une liste d’équations S ?= T
pairs([], [], []). % si les deux listes sont vides, le résultat est une liste vide

pairs([A1|Q1], [A2|Q2], [A1 ?= A2 | Q]) :- % création de l'équation entre les deux têtes
    pairs(Q1, Q2, Q). % récursion sur le reste des listes


