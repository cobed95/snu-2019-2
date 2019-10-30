type treasure = StarBox | NameBox of string
type key = Bar | Node of key * key

type map = End of treasure
         | Branch of map * map
         | Guide of string * map

type implication = ImplBar
                 | ImplNone
                 | ImplNode of implication * implication

type implicationTree = Leaf of key * treasure
                     | SinglePath of key * string * implicationTree
                     | DoublePath of key * implicationTree * implicationTree

exception IMPOSSIBLE
exception NotFound
exception KeyMismatch

let rec append filter kList key = 
    match kList with
    | head :: tail -> 
        if (filter key head) then kList
        else head :: (append filter tail key)
    | [] -> key :: kList 

let rec matchKey k1 k2 =
    match (k1, k2) with
    | (Bar, Bar) -> true
    | (Node (k1Left, k1Right), Node (k2Left, k2Right)) -> 
        (matchKey k1Left k2Left) && (matchKey k1Right k2Right)
    | (_, _) -> false 

let rec appendUniquely = append matchKey 

let extractKey implT =
    match implT with
    | Leaf (key, _) -> key
    | SinglePath (key, _, _) -> key
    | DoublePath (key, _, _) -> key 

let extractName treasure =
    match treasure with
    | StarBox -> None
    | NameBox name -> Some name

let rec getImpliedKeyForTreasure implT name =
    match implT with
    | Leaf (key, treasure) -> 
        let treasureName = extractName treasure in
        (match treasureName with
        | Some treasureName ->
            if name = treasureName then Some key
            else None
        | None -> None)
    | SinglePath (_, _, tree) -> getImpliedKeyForTreasure tree name
    | DoublePath (_, left, right) -> 
        let leftKeyOpt = getImpliedKeyForTreasure left name in
        let rightKeyOpt = getImpliedKeyForTreasure right name in
        (match (leftKeyOpt, rightKeyOpt) with
        | (Some leftKey, Some rightKey) -> 
            if leftKey = rightKey then rightKeyOpt
            else raise IMPOSSIBLE
        | (Some leftKey, None) -> leftKeyOpt
        | (None, Some rightKey) -> rightKeyOpt
        | (None, None) -> None)

let extractRight key =
    match key with
    | Node (left, right) -> right
    | _ -> raise IMPOSSIBLE 

let rec implication_of_key key =
    match key with
    | Node (left, right) ->
        ImplNode (implication_of_key left, implication_of_key right)
    | Bar -> ImplBar

let rec min_key_of_implication implication =
    match implication with
    | ImplNode (left, right) -> 
        Node (min_key_of_implication left, min_key_of_implication right)
    | _ -> Bar

let rec mapToImplicationTree map implication =
    match map with
    | End (treasure) -> 
        (match treasure with
        | NameBox(_) -> 
            Leaf (min_key_of_implication implication, treasure)
        | StarBox -> Leaf (Bar, treasure))
    | Branch (left, right) -> 
        let rightImplTree = mapToImplicationTree right ImplNone in
        let leftOfNextImplication = implication_of_key (extractKey rightImplTree) in
        let leftImplTree = 
            mapToImplicationTree left (ImplNode (leftOfNextImplication, implication)) in
        DoublePath((extractRight (extractKey leftImplTree)), leftImplTree, rightImplTree)
    | Guide (name, next) ->
        (match implication with
        | ImplNode (left, right) ->
            let implTree = mapToImplicationTree next right in
            let leftOfSelf = min_key_of_implication left in
            SinglePath (Node (leftOfSelf, (extractKey implTree)), name, implTree)
        | ImplNone -> 
            let implTree = mapToImplicationTree next implication in
            let keyOfTreasure = getImpliedKeyForTreasure implTree name in
            (match keyOfTreasure with
            | Some leftOfSelf -> 
                SinglePath (Node (leftOfSelf, (extractKey implTree)), name, implTree)
            | None -> raise IMPOSSIBLE)
        | ImplBar -> raise IMPOSSIBLE)

let rec verifyGuides implTree =
    match implTree with 
    | Leaf (_, _) -> true
    | SinglePath (key, name, next) ->
        let keyOpt = getImpliedKeyForTreasure next name in
        (match keyOpt with
        | Some keyOfTreasure ->
            (match key with
            | Node (left, right) ->
                if (matchKey keyOfTreasure left)
                then verifyGuides next
                else false
            | Bar -> false)
        | None -> false)
    | DoublePath (key, left, right) ->
        (verifyGuides right) && (verifyGuides left)

let rec reduceLeaves reducer acc implTree =
    match implTree with
    | Leaf (key, treasure) -> reducer acc key treasure
    | SinglePath (_, _, next) -> reduceLeaves reducer acc next
    | DoublePath (_, left, right) -> 
        let intermediate = reduceLeaves reducer acc left in
        reduceLeaves reducer intermediate right

let reducerToKeyTreasure acc key treasure = 
    let rec find acc treasure =
        match acc with
        | head :: tail -> 
            (match head with (key, t) -> 
                (match (treasure, t) with
                | (StarBox, StarBox) -> key
                | (NameBox(argName), NameBox(foundName)) ->
                    if argName = foundName then key
                    else find tail treasure
                | (_, _) -> find tail treasure))
        | [] -> raise (NotFound) in
    try 
        let k = find acc treasure in
        if (matchKey key k) then acc
        else raise (KeyMismatch)
    with NotFound -> (key, treasure) :: acc

let reducerToUniqueKeys acc key treasure = appendUniquely acc key

let uniqueKeyTreasurePairs = reduceLeaves reducerToKeyTreasure []
let rec collectKeys = reduceLeaves reducerToUniqueKeys [] 

let rec getReady m = 
    let implTree = mapToImplicationTree m ImplNone in
    if (verifyGuides implTree)
    then 
        try 
            let _ = uniqueKeyTreasurePairs implTree in
            collectKeys implTree
        with KeyMismatch -> raise IMPOSSIBLE
    else raise IMPOSSIBLE

