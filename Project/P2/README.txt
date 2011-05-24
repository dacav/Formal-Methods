--------------------------------------------------------------------------
                            About the project:
--------------------------------------------------------------------------

Three model files delivered in the "models" directory. Each file contains
a detailed explanation (comprehensive of CTL specifications).

Briefly:

    models/Golo1.smv

        First I spotted (by thinking) a possible solution. This model
        encodes such solution and verifies it.

    models/Golo2.smv

        The second version encodes a non-deterministic behavior on the
        hourglasses, so the system finds itself a possible solution for
        the problem.

    models/Golo3.smv

        This version fixes an unexpected (although not wrong) behavior of
        the system.

Checking and solution generation:

    The first model ("models/Golo1.smv") directly encodes solution. The
    checking is about safety (not overcooked) and liveness (eventually
    cooked) of the system.

    In the other two modules I checked for the reachability of the
    solution (which is what we want to prove).

    Also, since we want to obtain a solution, I manually inverted the
    reachability assertion in order to get a wrong execution and obtain
    the yearned path to the victory! :)

    The command I used:

        read_model -i Golo2.smv 
        go
        check_ctlspec -p "! EF AG egg_ready" -o ../executions/Golo2.trace

    I did the same for Golo3, obtaining the files "executions/Golo2.trace"
    and "executions/Golo3.trace". In order to easily understand the the
    traces I've also wrote a little tool.
    
    See the second "More automatic stuff!" for details.

About propagation delay:

    Each model reasonably encodes the cooking phase as a consequence of
    some event, so far the solution have a delay of one step due to the
    propagation of the event.

    For instance, if in some execution hourglass "h7" is expiring and we
    set the "cooking" variable to true, then the "egg" counter will start
    to be incremented only on the next step, namely when the "next"
    statement for the "egg" variable will notice that the "cooking"
    variable is no longer false.

    Of course the same reasoning is correct for the dual behavior, for
    which the "cooking" variable is put to false, and this makes the
    solution still valid, despite this tricky behavior.

--------------------------------------------------------------------------
                          More automatic stuff!
--------------------------------------------------------------------------

Reading the trace is boring. I wrote a little python script which fixes
the problem. It will produce an input suitable for the "dot" program,
which of course must be installed on your system (it's part of the
"graphviz" package).

The script is "scripts/mkdot", and it's used by the Makefile
to generate some the pdf I included with the project (they're stored in
the "executions" directory).

The generated graphs show the solution as sequence of nodes to follow.
Labels on edges give the sequentiality starting from 0 (from initial state
to following one).

Beyond the included ones, the following commands will generate some
significative graphs for the Golo3 model:

    scripts/mkdot egg h7.time event < executions/Golo3.trace | dot -Tpdf -o 1.pdf
    scripts/mkdot egg event < executions/Golo3.trace | dot -Tpdf -o 2.pdf
