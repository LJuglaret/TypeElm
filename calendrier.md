<!--
- title : representer correctement des donnees
- description :
- author : 
- theme : solarized.css
- transition : convex
- slideNumber : true -->

<style type="text/css">
  .reveal li code { font-size:  100%; width : 600pt; }
</style>


# representer correctement des donnees



---

## Exemple

```elm
type alias Date  = {jour : Int , mois : Int}

date0  : Date
date0 = {jour : 11 , 12}
--valide , represente le 11 decembre
date1  : Date
date1 = {jour : -7 , mois : 54} 
--non valide

```
---
Quel est le probleme

- jour est un entier relatif , or il doit etre dans intervalle dependant du mois
- mois est un entier relatif, or il doit etre compris entre 1 et 12

----

Exemples _

```elm
(jour = 11 , mois = 12) est une date valide 
```
mais
```elm
(jour = -2,jour =  36) est aussi une date valide ...
```
---

Debut de solution

- Representer les mois sous forme d une enumeration
``` elm
type Mois = Janvier
            |Fevrier
            |Mars
            |Avril
            .
            .
            .
```


---

Maintenant pour le jour


``` elm
Ce dont on aura besoin :
listeInfoMois : Mois -> {mois : Mois , numeroDuMois : Int, nombreDeJours : Int}
listeInfoMois m = 
        case m of
            Janvier  -> {mois = Janvier , numeroDuMois =1 , nombreDeJours = 31}
            Fevrier  -> {mois = Fevrier , numeroDuMois =2 , nombreDeJours = 27}
            Mars     -> {mois = Mars    , numeroDuMois =3 , nombreDeJours = 31} 
            .
            .
            .
```
toutes les informations concernant chaque mois

----
premiere solution
```elm
jourDateValide : Date -> Maybe Date
jourDateValide date = 
    let 
        jour = date.jour
        mois = date.mois 
    in
        if (jour> 0 && jour <= (listeInfoMois mois).nombreDeJours)
        then Just date
        else Nothing

```
probleme : sous cette forme ce n est pas un type

----

Autre Solution

```elm
module Odd exposing (newDate,Date,DateAlias, dateVersAlias)

type alias DateAlias  = {jour : Int ,  mois : Mois}
type Date = D {jour : Int ,  mois : Mois}
newDate : DateAlias -> Maybe Date
newDate date = 
    let 
        jour = date.jour
        mois = date.mois 
    in
        if (jour> 0 && jour <= (listeInfoMois mois).nombreDeJours) then Just (D date)
        else Nothing
```

---
Avantage
Avec cette forme on a la garantie que pour toute date
 entree elle sera soit valide et sera traitee
soit invalide et ne renverra rien
----



Ce que l on peut faire 

- Creer un calendrier
    - Un calendrier est une liste de couples {date, evenement}
    ```elm
    type  alias  Calendrier  = List{ date : { jour : Int , mois : Mois }
                                , evenement : Evenement
                            }
    ```
    - Concernant les evenements il faut pouvoir :
        - ajouter un evenement a une date
        -  ajouter un evenement sur un intervalle de date

    ---
    ```elm
ajoutEvenement : Calendrier -> Evenement -> Maybe Date -> Calendrier 
ajoutEvenement cal evt date = 
    case date of
        Just date -> 
            let  
                jour  = (dateVersAlias  date).jour
                mois  = (dateVersAlias  date).mois
            in [{ date = {jour = jour, mois = mois},evenement = evt}]
        Nothing   -> cal

    ```elm
  repeterEvenement : Calendrier -> Evenement -> Maybe Date -> Maybe Date -> Calendrier
repeterEvenement cal evt date1 date2 =
    case (date1,date2) of 
        (Just date1,Just date2) ->
            let (jour1,mois1, jour2 , mois2) = ((dateVersAlias  date1).jour,(dateVersAlias  date1).mois,(dateVersAlias  date2).jour,(dateVersAlias  date2).mois)
            in
                if (mois1 == mois2 )
                    then
                    if (jour1<=jour2)
                    then List.append (ajoutEvenement cal evt (Just date1)) (repeterEvenement cal evt (jourSuivant (Just date1)) (Just date2) )
                    else  cal
                else
                    if (jour1 <(listeInfoMois mois1).nombreDeJours)
                    then  {date = {jour = jour1 + 1, mois = mois1} ,evenement = evt} :: (repeterEvenement cal evt (jourSuivant (Just date1)) (Just date2 ))
                    else {date = {jour = 1 , mois = complete ( (listeInfoMois mois1).numeroDuMois + 1 ) correspondances} ,evenement = evt} :: (repeterEvenement cal evt (jourSuivant (Just date1) ) (Just date2) )

        (_, _) -> cal
    ```
    ----
    Exemples
    ```elm
      sortie1  : Evenement
      sortie1 = 
      Sortie {qui = {nom = "p",prenom= ""} , lieu = "paris" , description = "cine"}

      evt : Evenement
      evt = Vacances

    date1  : Maybe Date
    date1 =   newDate {jour  = 15, mois = Octobre}

    date2  : Maybe Date
    date2 =  newDate {jour  = 4, mois = Novembre}

    vacances1 : Calendrier
    vacances1 = repeterEvenement cal evt date1 date2

    anniversaire1 : Calendrier
    anniversaire1 = [ {date =  {jour  = 19, mois = Octobre}, 
         evenement = Anniversaire  { nom  = "No" , prenom = "Pr"}
         }
        ]

    calendrier2 : Calendrier 
    calendrier2 = triCalendrier (List.append vacances1 anniversaire1)
    s = parcoursCalendrier calendrier2
    ```
----

