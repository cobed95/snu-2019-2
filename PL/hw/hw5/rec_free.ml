type inductive_data = InductiveCase of data
                    | BaseCase

let iterate a = 
    match a with
    | InductiveCase(inner_data) -> f inner_data
    | BaseCase -> terminate a

let terminate a = a

let f a = 
    match a with
    | InductiveCase(inner_data) -> iterate inner_data
    | BaseCase -> terminate a

