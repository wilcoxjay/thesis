PB (S) :=
  Name := Primary | Backup

  Msg := Replicate S.Inp | Ack
  Inp := S.Inp
  Out := { request: S.Inp; response: S.Out }
  State (n: Name) = { queue: list S.Inp;
                      underlying_state: S.State }

  InitState (n: Name) = { queue := [];
                          underlying_state := S.InitState n }

  HandleInp (n: Name) (s: State n) (inp: Inp) :=
    if n == Primary then
      append_to_queue inp;;
      if length s.queue == 1 then
        (* if not already replicating a request *)
        send (Backup, Replicate (head s.queue))
                          
  HandleMsg (n: Name) (s: State n) (src: Name) (msg: Msg) :=
    match n, msg with
      | Primary, Ack =>
        out := apply_entry (head s.queue);;
        output { request := head s.queue; response := out };;
        pop s.queue;;
        if s.queue != [] then
          send (Backup, Replicate (head s.queue))
      | Backup, Replicate i =>
        apply_entry i;;
        send (Primary, Ack)
