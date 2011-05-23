#define N_TRAINS 3

mtype {

    /* ---- Values for signal light ------------------------------------ */

    green,      // Green semaphore
    red,        // Red semaphore

    /* ---- Messages between Operator A and Operator B ----------------- */

    msg0,       // Message: Train in
    msg1,       // Message: Tunnel free
    msg2,       // Message: Has train left?

};

/* Status of the system */
mtype sig_light = green;        // 0 = red; 1 = green
int trains_in_tunnel = 0;       // 0 = free; 1 = in use; >1 = error

/* Bell rings if device fails */
bool bell = false;

/* Communication among operators */
chan msg_AB = [1] of { mtype, int }
chan msg_BA = [1] of { mtype, int }

active [N_TRAINS] proctype Train ()
{
    atomic {
        // Here we got the problem: if the next train arrives before
        // Operator A manually sets the signal light, the protocol is
        // broken.
        (sig_light == green);
        if
        :: sig_light = red;
        :: bell = true;
        fi
        printf("Train in!\n");
        trains_in_tunnel ++;
    }

    atomic {
        trains_in_tunnel --;
        printf("Train out\n");
    }
}

inline signal_train_in (cnt)
{
    atomic {
        msg_AB! msg0, cnt;
        printf("MSG: Train entered!\n");
    }
}

active proctype OperatorA ()
{
    bit sent = false;
    int cnt = 0;

    // Communication input data
    mtype ref_msg;
    int ref_cnt;

end1:       // Ends when signal light never gets red again
    do
        :: !sent && bell ->
            printf("Heard bell! Setting light manually");
            sig_light = red;
            signal_train_in(cnt);
            sent = true;

        :: !sent && sig_light == red ->
            printf("Light is red\n");
            signal_train_in(cnt);
            sent = true;

        :: sent ->
            do
                :: (empty(msg_BA) && empty(msg_AB)) ->
                    // I sent the message, OpB read it but didn't answer
                    atomic {
                        msg_AB ! msg2, cnt;
                        printf("MSG: Is the train still in?\n");
                    }

                :: nempty(msg_BA) ->
                    msg_BA ? ref_msg, ref_cnt;
                    if
                        :: (ref_cnt == cnt) ->
                            // successfull train passing operation
                            printf("Train %d is gone\n", ref_cnt);
                            atomic {
                                sig_light = green;
                                printf("Light is green\n");
                            }
                            sent = false;
                            cnt ++;
                            break;

                        :: else ->
                            printf("Dropping old message (%d != %d)\n", ref_cnt, cnt);
                            skip;

                    fi;

            od;
    od
}

active proctype OperatorB ()
{
    int id;
    mtype msg;

end1:       // Ends when queue is empty forever
    do ::

        nempty(msg_AB);
        atomic {
            msg_AB ? msg, id;
            printf("Got message refering to train %d\n", id);
        }
        if
            :: msg == msg0 ->
                printf("Seen train GTFOing\n");
                (trains_in_tunnel == 0);
                atomic {
                    printf("MSG: Tunnel is free\n");
                    msg_BA ! msg1, id;
                }

            :: msg == msg0 ->
                printf("Forgetting to watch\n");

            :: msg == msg2 ->
                printf("Observing until train GTFOs\n");
                (trains_in_tunnel == 0);
                atomic {
                    printf("MSG: Tunnel is free!\n");
                    msg_BA ! msg1, id;
                }

        fi;
    od;
}

/*

    To notice:

        Communication channels are supposed to be reliable. The checking
        empty(channel) corresponds to getting confirmation about a correct
        deliverying of the message.

 */
