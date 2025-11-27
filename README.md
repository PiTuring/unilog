```
  _    _       _ _                 
 | |  | |     (_) |                
 | |  | |_ __  _| |     ___   __ _ 
 | |  | | '_ \| | |    / _ \ / _` |
 | |__| | | | | | |___| (_) | (_| |
  \____/|_| |_|_|______\___/ \__, |
                              __/ |
                             |___/ 
```


  **Université** : Université de Lorraine (Nancy) — Département Informatique<br/>
  **Module** : M1 S7 — Logiques et modèles de calcul<br/>
  **Auteur** : PiTuring<br/>
  **Encadrant** : Didier Galmiche<br/>
  **Année universitaire** : 2025-2026<br/>
  **Licence** : MIT — voir `LICENSE`

---

## 📌 Présentation

Ce dépôt contient une implémentation pédagogique en Prolog de l'algorithme d'unification de Martelli-Montanari. L'objectif est d'offrir :

- une implémentation claire des règles de transformation (rename, simplify, decompose, orient, expand, check, clash),
- plusieurs stratégies de sélection d'équation (premier, pondéré, dynamique, ...),
- une interface simple pour exécuter et tracer les étapes de l'unification.

Ce projet est idéal pour l'étude des systèmes de réécriture orientés, des algorithmes d'unification et des stratégies de choix d'application de règles.

---

## 🔧 Prérequis

- SWI-Prolog (version recommandée : 8.x ou supérieure)
- macOS/Linux : gestionnaire Homebrew pour l'installation rapide

---

## ⚙️ Installation

macOS (Homebrew) :

```bash
brew install swi-prolog
```

Linux (Debian/Ubuntu) :

```bash
sudo apt update
sudo apt install swi-prolog
```

Windows : télécharger SWI-Prolog depuis le site officiel https://www.swi-prolog.org/ et installer le binaire.

---

## 🚀 Démarrage rapide

1) Ouvrir un shell Prolog (swipl) à la racine du projet :

```bash
swipl
```

2) Charger le module principal `unif.pl` (qui charge automatiquement `utils.pl`, `regles.pl` et `strategies.pl`) :

```prolog
?- ['src/unif.pl'].
```

3) Exemples d'appels :

```prolog
?- unifie([X ?= a]).
% Expected output:
% X = a
% Yes

?- unifie([f(X, a) ?= f(b, Y), X ?= b], choix_premier).
% Example output: prints substitution and Yes/No depending on success

?- unif([f(X) ?= f(a), X ?= b], choix_pondere_4).
% Run without trace (clr_echo)

?- trace_unif([f(X) ?= f(a), X ?= a], choix_premier).
% Run with trace (set_echo) to get step-by-step logging
```

> Remarque : l'opérateur `?=` est défini dans `utils.pl` via `op(20, xfy, ?=)`, et la sortie des substitutions se fait via `ecrire_substitution/1`.

---

## 🧭 Guide d'utilisation & API (prédicats clés)

- `unifie(P)` : applique la stratégie par défaut `choix_premier` sur le système d'équations `P`.
- `unifie(P, Strategie)` : applique la stratégie nommée `Strategie` (ex. `choix_premier`, `choix_pondere_4`, `choix_pondere_dyn`).
- `unif(P, Strategie)` : exécute l'unification sans trace (désactive `echo`).
- `trace_unif(P, Strategie)` : même que `unif/2` mais avec la trace activée (log via `echo`).

- `resout(P, S, Strategie, R)` : prédicat interne qui résout le système d'équations `P` avec la substitution `S` sous la stratégie `Strategie`, renvoyant `R` (substitution finale) ou `echec`.

---

## 🗂️ Structure du projet

```
src/
  ├─ utils.pl           # opérateurs, affichage (echo), ecrire_substitution
  ├─ regles.pl          # implémentation des règles de Martelli-Montanari (decompose, expand, orient, ...)
  ├─ strategies.pl      # stratégies de sélection : choix_premier, choix_pondere_*, dynamique, etc.
  └─ unif.pl            # prédicats d'interface : unifie/unif/trace_unif et moteur resout/4
```

---

## 🔬 Exemples & Cas d'usage

1) Unification directe (succès simple) :

```prolog
?- unifie([X ?= a]).
% X = a
% Yes
```

2) Unification avec décomposition :

```prolog
?- unifie([f(X, a) ?= f(b, Y), X ?= b], choix_premier).
% Steps: decompose, simplify/rename etc. -> substitution possible ou echec
```

3) Détection d'échec :

```prolog
?- unifie([f(a) ?= g(b)], choix_premier).
% No
```

4) Tracing : suivre chaque étape

```prolog
?- trace_unif([X ?= f(X)], choix_premier).
% trace shows occur_check and leads to echec
```

---

## ✅ Stratégies disponibles

- `choix_premier/4` — première équation trouvée
- `choix_pondere_1/4` à `choix_pondere_5/4` — différentes tables de poids
- `choix_pondere_dyn/4` — stratégie dynamique basée sur le poids et la taille des termes

Ces stratégies sont définies dans `src/strategies.pl` et peuvent être étendues facilement.

---

## ✍️ Contribuer

Contributions bienvenues :

1) Ouvrez un ticket décrivant l'amélioration souhaitée.
2) Créez une branche dédiée, puis envoyez une Pull Request avec des explications et tests si nécessaire.

Avant une PR :
- Documentez la fonctionnalité
- Ajoutez des exemples et tests (si vous ajoutez des prédicats)

---

## 📖 Références

- G. Martelli, U. Montanari — "An Efficient Unification Algorithm" (1982) (algorithme étudié ici)

---

## 📝 Licence

Ce projet est distribué sous la licence MIT. Voir le fichier `LICENSE` pour le texte complet de la licence.

---

## Auteur

PiTuring — Implementation pédagogique et didactique — M1 S7, Master Informatique.

---


