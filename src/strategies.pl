% strategies.pl ----------------------------------------------------------------------------------------

% Prédicats de stratégies de choix de règle

% choix_premier(P, Q, E, R) : stratégie de choix de la première équation dans la liste P
%                             Q est la liste P sans l'équation E
%                             R est la règle applicable à l'équation E
%                             E est la première équation de P pour laquelle une règle s'applique
%                             où P est une liste d'équations de la forme X ?= T
%                             Q est une liste d'équations de même forme 
%                             E est une équation de la forme X ?= T
%                             R est un atome représentant le nom de la règle
choix_premier([E|P], P, E, R) :- % essayer la première équation E de P
    regle(E, R). % si une règle R s'applique à E, on la choisit

% Exemple stratégie du sujet :
% Liste des poids pour la stratégie choix_pondere_1 pour chaque règle :
poids_1(clash, 5).
poids_1(check, 5).
poids_1(rename, 4).
poids_1(simplify, 4).
poids_1(orient, 3).
poids_1(decompose, 2).
poids_1(expand, 1).
poids_1(trivial, 0).

% choix_pondere_1(P, Q, E, R) : stratégie de choix pondéré dans la liste P avec la table poids_1
%                               E est l'équation sélectionnée
%                               R est la règle associée à cette équation
%                               où P est une liste d'équations de la forme X ?= T
%                               Q est une liste d'équations de même forme 
%                               E est une équation de la forme X ?= T
%                               R est un atome représentant le nom de la règle
choix_pondere_1(P, P2, Eselectionnee, Rselectionnee) :-
    findall(W-E-R,
        (member(E,P), regle(E,R), poids_1(R,W)),
        Liste), % construire une liste [poids-equation-regle, ...]
    max_member(Wmax-Eselectionnee-Rselectionnee, Liste), % trouver le poids maximum
    select(Eselectionnee, P, P2). % enlever Eselectionnee du système

% Stratégie + simple d'abord :
poids_2(simplify, 5).
poids_2(rename, 5).
poids_2(orient, 4).
poids_2(decompose, 3).
poids_2(expand, 2).
poids_2(clash, 1).     
poids_2(check, 1).
poids_2(trivial, 0).

% choix_pondere_2(P, Q, E, R) : stratégie de choix pondéré dans la liste P avec la table poids_2
%                               même signification que pour choix_pondere_1/4
choix_pondere_2(P, P2, Eselectionnee, Rselectionnee) :-
    findall(W-E-R,
        (member(E,P), regle(E,R), poids_2(R,W)),
        Liste), % construire une liste [poids-equation-regle, ...]
    max_member(Wmax-Eselectionnee-Rselectionnee, Liste), % trouver le poids maximum
    select(Eselectionnee, P, P2). % enlever Eselectionnee du système

% Stratégie détection d'échec prioritaire :
poids_3(clash, 6).
poids_3(check, 5).
poids_3(decompose, 4).
poids_3(expand, 3).
poids_3(simplify, 2).
poids_3(rename, 2).
poids_3(orient, 1).
poids_3(trivial, 0).

% choix_pondere_3(P, Q, E, R) : stratégie de choix pondéré dans la liste P avec la table poids_3
%                               même signification que pour choix_pondere_1/4
choix_pondere_3(P, P2, Eselectionnee, Rselectionnee) :-
    findall(W-E-R,
        (member(E,P), regle(E,R), poids_3(R,W)),
        Liste), % construire une liste [poids-equation-regle, ...]
    max_member(Wmax-Eselectionnee-Rselectionnee, Liste), % trouver le poids maximum
    select(Eselectionnee, P, P2). % enlever Eselectionnee du système

% Stratégie classique du cours :
poids_4(rename, 6).
poids_4(simplify, 6).
poids_4(check, 5).
poids_4(clash, 5).
poids_4(expand, 4).
poids_4(orient, 3).
poids_4(decompose, 2).
poids_4(trivial, 0).

% choix_pondere_4(P, Q, E, R) : stratégie de choix pondéré dans la liste P avec la table poids_4
%                               même signification que pour choix_pondere_1/4
choix_pondere_4(P, P2, Eselectionnee, Rselectionnee) :-
    findall(W-E-R,
        (member(E,P), regle(E,R), poids_4(R,W)),
        Liste), % construire une liste [poids-equation-regle, ...]
    max_member(Wmax-Eselectionnee-Rselectionnee, Liste), % trouver le poids maximum
    select(Eselectionnee, P, P2). % enlever Eselectionnee du système

% Stratégie + couteuse d'abord :
poids_5(decompose, 6).
poids_5(clash, 5).
poids_5(check, 5).
poids_5(expand, 4).
poids_5(simplify, 3).
poids_5(rename, 3).
poids_5(orient, 2).
poids_5(trivial, 0).

% choix_pondere_5(P, Q, E, R) : stratégie de choix pondéré dans la liste P avec la table poids_5
%                               même signification que pour choix_pondere_1/4
choix_pondere_5(P, P2, Eselectionnee, Rselectionnee) :-
    findall(W-E-R,
        (member(E,P), regle(E,R), poids_5(R,W)),
        Liste), % construire une liste [poids-equation-regle, ...]
    max_member(Wmax-Eselectionnee-Rselectionnee, Liste), % trouver le poids maximum
    select(Eselectionnee, P, P2). % enlever Eselectionnee du système

% Stratégie poids dynamique :
poids_base(clash, 6).
poids_base(check, 5).
poids_base(rename, 4).
poids_base(simplify, 4).
poids_base(orient, 3).
poids_base(decompose, 2).
poids_base(expand, 1).
poids_base(trivial, 0).

% taille(T, N) : calcule la taille du terme T
%                N est la taille de T
%                où T est un terme (variable, constante ou terme composé)
%                N est un entier naturel
taille(T, 1) :-
    var(T), !. % une variable a une taille de 1

taille(T, 1) :-
    atomic(T), !. % une constante a une taille de 1

taille(T, N) :-
    compound(T), % T est un terme composé
    T =.. [_|Args], % décomposer T en sa liste d'arguments Args
    tailles_args(Args, S), % calculer la somme des tailles des arguments
    N is 1 + S. % taille totale = 1 (pour le symbole de fonction) + somme des tailles des arguments

taille(_, 1).  % cas par défaut 

% tailles_args(Args, S) : calcule la somme des tailles des termes dans la liste Args
%                         S est la somme des tailles
%                         où Args est une liste de termes
%                         S est un entier naturel
tailles_args([], 0). % liste vide : somme des tailles est 0

tailles_args([A|Q], S) :-
    taille(A, SA), % taille du premier argument
    tailles_args(Q, SQ), % somme des tailles des arguments restants
    S is SA + SQ. % somme totale

% poids_dyn(E, R, PoidsFinal) : calcule le poids dynamique de l’équation E selon la règle R
%                               PoidsFinal est le poids dynamique calculé
%                               où E est une équation de la forme X ?= T
%                               R est un atome représentant le nom de la règle
%                               PoidsFinal est un entier naturel
poids_dyn(E, R, PoidsFinal) :-
    regle(E, R), % déterminer la règle
    poids_base(R, PB), % récupérer son poids de base
    E = (_ ?= T), % extraire le terme droit de l’équation
    taille(T, TailleT), % calculer sa taille
    PoidsFinal is PB - TailleT. % poids ajusté

% choix_pondere_dyn(P, Q, E, R) : sélectionne l’équation avec le poids dynamique le plus élevé
%                                 même signification que pour choix_pondere_1/4
choix_pondere_dyn(P, P2, Eselectionnee, Rselectionnee) :-
    findall(W-E-R,
        ( member(E, P),
          regle(E, R),
          poids_dyn(E, R, W)
        ),
        Liste), % construire une liste [poids-equation-regle, ...]
    max_member(_-Eselectionnee-Rselectionnee, Liste), % trouver le poids maximum
    select(Eselectionnee, P, P2). % enlever Eselectionnee du système
