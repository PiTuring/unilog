% utils.pl ----------------------------------------------------------------------------------------

:- op(20,xfy,?=).

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).

% Prédicat d'affichage rajoutés

% echo_nl: si le flag echo_on est positionné, echo_nl affiche un saut de ligne
%          sinon, echo_nl réussit simplement en ne faisant rien. 
echo_nl :- echo_on, !, nl.
echo_nl.

% ecrire_substitution(S): affiche la substitution S, où S est une liste d'assignations de la forme X = T
ecrire_substitution([]). % S est vide : rien à afficher
ecrire_substitution([X = T | S]) :-   
    write(X), write(' = '), write(T), nl, % afficher l'assignation X = T
    ecrire_substitution(S). % continuer avec le reste de la substitution S
