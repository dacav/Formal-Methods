#define N_TRAINS 3

mtype {
    msg0,       /* Message: "train in tunnel" */
    msg1        /* Message: "has train left the tunnel?" */
    msg2,       /* Message: "tunnel is free" */
};

bit sig_light = 1;      /* 0 = red; 1 = green */
bit tunnel_status = 0;  /* 0 = free; 1 = in use */

/* Telegraph from A to B */
chan tel_toB = [1] of { mtype };

/* Telegraph from B to A */
chan tel_toA = [1] of { mtype };

inline send_to_B (info)
{
    atomic {
        tel_toB! info;
        printf("Message A =%e=> B\n", info);
    }
}

inline send_to_A (info)
{
    atomic {
        tel_toA! info;
        printf("Message B =%e=> A\n", info);
    }
}

inline flush (tel)
{
    mtype drop;

    do
    :: empty(tel) -> break;
    :: nempty(tel) -> tel? drop;
    od
}


/* Number of trains which passed tunnel */
int gone = 0;

active [N_TRAINS] proctype Train ()
{
    atomic {
        (sig_light == 1);
        sig_light = 0;
        printf("Train id=%d entering\n", _pid);
        tunnel_status ++;
    }

    printf("Train id=%d exiting\n", _pid);
    tunnel_status --;
    gone ++;
}

active proctype OperatorA ()
{
    mtype in_msg;

    do

    :: gone == N_TRAINS ->    /* Exit condition (all trains are gone) */

        printf("OpA says all trains gone.\n");
        break;

    :: else ->

        (sig_light == 0);       /* Wait until a train enters */
        printf("OpA sees the red light\n");
        send_to_B(msg0);        /* Telegraph that to Operator B */

        do

        :: empty(tel_toA) ->
            printf("OpA thinks B probably forgot and wakes him up\n");
            send_to_B(msg1);    /* No messages: ask. */

        :: nempty(tel_toA) ->               /* Got message. */
            printf("OpA got message, sets semaphore to green\n");
            tel_toA? in_msg;                /* Train eventually gone. */
            sig_light = 1;
            break;

        od;

    od;

    printf("OpA says Goodbye\n");
}

active proctype OperatorB ()
{
    mtype in_msg;

    do

    :: gone == N_TRAINS ->    /* Exit condition (all trains are gone) */

        printf("OpB says all trains gone.\n");
        break;

    :: else ->

        tel_toB? in_msg;

        if
        :: in_msg == msg0 ->        /* Train entered the tunnel */

            printf("OpB is informed the train the tunnel\n");
            if
            :: tunnel_status == 0 ->
                printf("OpB sees the train exiting\n");
                send_to_A(msg1);    /* I was checking */
            :: printf("OpB forgets to watch, reading a magazine instead...\n");
            :: printf("OpB forgets to watch, watches tv instead...\n");
            :: printf("OpB forgets to watch, girlfriend called him...\n");
            fi;

        :: in_msg == msg1 ->        /* Operator A asked status */
            (tunnel_status == 0);   /* Stay focused, check status */
            printf("OpB sees the empty tunnel\n");
            atomic {
                send_to_A(msg1);
                flush(tel_toB);
            }

        fi;

    od;

    printf("OpA says Goodbye\n");
}

