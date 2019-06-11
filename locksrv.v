(* 1 - node identifiers *)
Name := Server | Agent(int)

(* 2 - API, also known as external IO *)
Inp := Lock | Unlock
Out := Grant
(* 2 - network messages *)
Msg := LockMsg | UnlockMsg | GrantMsg

(* 3 - state *)
State (n: Name) :=
  match n with
    | Server => list Name (* head = agent holding lock      *)
                          (* tail = agents waiting for lock *)
    | Agent n => bool     (* true iff this agent holds lock *)

InitState (n: Name) : State n :=
  match n with
    | Server => []
    | Agent n => false

(* 4 - handler for external input *)
HandleInp (n: Name) (s: State n) (inp: Inp) :=
  match n with
    | Server => nop   (* server performs no external IO *)
    | Agent n =>
      match inp with
        | Lock =>                     (* client requests lock   *)
          send (Server, LockMsg)      (* forward to Server      *)
        | Unlock =>                   (* client requests unlock *)
          if s == true then (         (* if lock held           *)
            s := false;;              (* update state           *)
            send (Server, UnlockMsg)) (* tell Server lock freed *)

(* 4 - handler for network messages *)
HandleMsg (n: Name) (s: State n) (src: Name) (msg: Msg) :=
  match n with
    | Server =>
      match msg with
        | LockMsg =>
          (* if lock not held, immediately grant *)
          if s == [] then send (src, GrantMsg);;
          (* add requestor to end of queue *)
          s := s ++ [src]
        | UnlockMsg =>
          (* head of queue no longer holds lock *)
          s := tail s;;
          (* grant lock to next waiting agent, if any *)
          if s != [] then send (head s, GrantMsg)
        | _ => nop (* never happens *)
    | Agent n =>
      match msg with
        | GrantMsg =>      (* lock acquired    *)
          s := true;;      (* update state     *)
          output Grant     (* notify listeners *)
        | _ => nop         (* never happens    *)
