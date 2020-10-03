let rec f = fn x =>
  if x = 0 then f 1
  else f 2
in
  f 1
end

