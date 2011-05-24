--------------------------------------------------------------------------
                            About the project:
--------------------------------------------------------------------------

Two models delivered:

    Clayton0.pml

        Trains are simple and stright procedures, simply entering the
        tunnel and exiting, without cycles.

        Entering the tunnel consists in checking the signal light to be
        green and setting it to red. Such a procedure is atomic.

        Communication from OperatorA to OperatorB and from OperatorB to
        OperatorA is achieved by means of two communication channels
        emulating the telegraph behavior.

        Communication channels are supposed to be reliable. The checking
        empty(channel) corresponds to getting confirmation about a correct
        deliverying of the message.

        Each message is composed by an enumerative (giving the semantics
        of the message) and by an integer identifying the train which
        the message refers to.

        OperatorA keeps a train counter: when sending a message to
        OperatorB the counter is attached. OperatorB answers to a
        certain message by including the identifer. This allows OperatorA
        to discard old answers (avoiding ambiguity about which train
        exited the tunnel).

    Clayton1.pml

        The model works eactly like Clayton0 except the "bell" is added.
        When the train passes the tunnel we can have one of the following
        two possible behaviors: the semaphore gets red or the "bell"
        variable is set to true.

        The first behavior makes the system work exactly like in Clayton0,
        while the second breaks the mutual exclusion, since the red
        semaphore is not set atomically along with the semaphore checking
        operation (OperatorA is in charge of doing it).

Both models declare the following constraints to be checked:

    ->  Mutual exclusion for the tunnel:

            #define safe (trains_in_tunnel <= 1)

    ->  Liveness for the system (sooner or later all trains will pass the
        tunnel):

            #define sound (trains_out_tunnel == N_TRAINS)

--------------------------------------------------------------------------
                 Automatic stuff - I love automatic stuff
--------------------------------------------------------------------------

There's a Makefile inside the directory. You may need to the first line
depending on what's the name of the spin executable on your own system.

After that step, by calling "make" (no parameters are needed) you will
automatically:

    (1) Generate the files safe.pml and sound.pml corresponding
        respectively to the never-claims: '<> !safe' and '[] !sound'

    (2) For each of them generate a "pan" model checking program,
        compile it, run it and produce execution trails. The only needed
        trail in this case is for Clayton1.

By calling "make clean" all the garbage will be cleaned (only the original
files and the generated trails will be kept).

Note:   The compilation is achieved with the -DFBS flag (thus the
        generated trail will be as short as possible. The behavior can be
        modified by editing the makefile, row 5.

