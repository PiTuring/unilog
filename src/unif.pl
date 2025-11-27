% unif.pl ----------------------------------------------------------------------------------------

:- ['utils.pl'].
:- ['regles.pl'].
:- ['strategies.pl'].

% Prédicats d'unification

% unifie(P, S) : unifie la liste d'expressions P en utilisant la stratégie S
%                où P est une liste d'équations de la forme X ?= T 
%                et S le nom de prédicat d'une stratégie de choix de règle
%                (ex : choix_premier, choix_pondere_4, choix_pondere_5, choix_pondere_dynamique)
%                affiche la substitution et 'Yes' si l'unification réussit
%                affiche 'No' si l'unification échoue
unifie(P, S) :-
    resout(P, [], S, Resultat),  % début S = liste vide
    (Resultat == echec -> % si 'Resultat' est échec
        nl, write('No'), nl % afficher 'No'
    ;
        nl, ecrire_substitution(Resultat), nl, write('Yes') % sinon afficher la substitution et 'Yes'
    ).

% unifie(P) : unifie la liste d'expressions P en utilisant la stratégie par défaut choix_premier
%             P de même signification que pour unifie/2
unifie(P) :- unifie(P, choix_premier).

% unif(P,S) : exécute l'unification sans trace avec la stratégie S
%             P et S de même signification que pour unifie/2
unif(P, S) :-
    clr_echo, % désactive la trace par echo/1
    unifie(P, S). % exécute l'unification

% trace_unif(P,S) : exécute l'unification avec trace activée avec la stratégie S
%                   P et S de même signification que pour unifie/2
trace_unif(P, S) :-
    set_echo, % active la trace par echo/1
    unifie(P, S). % exécute l'unification

% Prédicat auxiliaire de résolution

% resout(P, S, Strategie, R) : résout le système d'équations P avec la substitution S
%                              en utilisant la stratégie de choix de règle Strategie
%                              et retourne le résultat R (substitution finale ou échec)
%                              où P est une liste d'équations de la forme X ?= T
%                              S est une liste d'assignations de la forme X = T
%                              Strategie est le nom d'un prédicat de stratégie de choix de règle
%                              R est soit une substitution (liste d'assignations) soit le terme echec
% Cas de base : système vide
resout([], S, _, S). % P est vide : on a terminé, R = S

% Boucle de résolution avec trace optionnelle via echo/1
resout(P, S, Strategie, R) :-
    echo('system: '), echo(P), echo_nl, % afficher le système courant si la trace est active
    call(Strategie, P, P2, E, Rg), % choisir une règle Rg et une équation E dans P selon la stratégie
    echo(Rg), echo(': '), echo(E), echo_nl, % afficher la règle appliquée
    reduit(Rg, E, (P2, S), P3S3), % appliquer la règle Rg à l'équation E dans le contexte (P2, S)
    ( P3S3 == echec -> % si l'application de la règle a échoué
        R = echec % on retourne échec
    ;   
        P3S3 = (P3,S3), % sinon, on décompose le nouveau système
        resout(P3, S3, Strategie, R) % sn continue la résolution avec le nouveau système
    ). 

% Cas d'échec : aucune règle ne s'applique
resout(_, _, _, echec). % si aucune règle ne s'applique, échec
