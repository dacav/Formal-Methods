#define N_TRAINS 3

mtype {

    /* ---- Values for signal light ------------------------------------ */

    green,      /* Green semaphore */
    red,        /* Red semaphore */

    /* ---- Messages between Operator A and Operator B ----------------- */

    none,       /* No communication */
    msg0,       /* Train in */
    msg1,       /* Tunnel free */
    msg2,       /* Has train left? */

};

/* Status of the system */
mtype sig_light = green;        // 0 = red; 1 = green
byte trains_in_tunnel = 0;      // 0 = free; 1 = in use; >1 = error

/* Communication among operators */
mtype msg_AB = none;
mtype msg_BA = none;

active [N_TRAINS] proctype Train ()
{
    atomic {
        (sig_light == green);
        sig_light = red;
        printf("Train in!\n");
        trains_in_tunnel ++;
    }

    atomic {
        trains_in_tunnel --;
        printf("Train out\n");
    }

}

active proctype OperatorA ()
{
    bit sent = false;
end:
    do
        :: !sent && sig_light == red ->
            printf("Light is red\n");
            atomic {
                msg_AB = msg0;
                printf("MSG: Train entered!\n");
            }
            sent = true;

        :: sent ->
            if
                :: (msg_BA == none && msg_AB == none) ->
                    // I sent the message, OpB read it but didn't answer
                    atomic {
                        msg_AB = msg2;
                        printf("MSG: Is the train still in?\n");
                    }

                :: atomic { msg_BA == msg1; msg_BA = none } ->
                    atomic {
                        sig_light = green;
                        printf("Light is green\n");
                    }
                    sent = false;

            fi
    od
}

active proctype OperatorB ()
{
end:
    do
        :: atomic { msg_AB == msg0; msg_AB = none } ->
            if
                // Operator actually waits for the train
                :: true ->
                    printf("Seen train GTFO\n");
                    (trains_in_tunnel == 0);
                    atomic {
                        printf("MSG: Tunnel is free\n");
                        msg_BA = msg1;
                    }

                // Operator forgets about the train
                :: true ->
                    printf("Forgetting to watch\n");

            fi;

        :: atomic { msg_AB == msg2; msg_AB = none } ->
            // Operator checks the train for sure
            printf("Observing until train GTFO\n");
            (trains_in_tunnel == 0);
            atomic {
                printf("MSG: Tunnel is free!\n");
                msg_BA = msg1;
            }
            break;

    od;
}

