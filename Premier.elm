module Premier exposing (Premier, newPremier, versPremier)

type Premier = C Int

newPremier : Int -> Maybe Premier
newPremier x = 
    let l = List.range 2 (x - 1)
    in 
        if (List.length (List.filter (\y ->  (x%y == 0)) l ) == 0) 
        then Just (C x)
        else Nothing
    
versPremier : Premier -> Int 
versPremier (C x) = x

suivantPremier : Maybe Premier -> Maybe Premier
suivantPremier x = 
    case x of 
        Just x -> newPremier ((versPremier x) + 1)
        _      -> Nothing

{-listeDePremiers : Maybe Premier -> Maybe Premier -> List Premier
listeDePremiers p1 p2 = 
    case (p1, p2) of 
        (Just p1, Just p2) ->  
        (_ , _)

-}