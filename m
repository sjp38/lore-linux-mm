Received: from scratchy (jdc.math.uwo.ca [129.100.75.19])
	by pony.its.uwo.ca (8.10.0/8.10.0) with ESMTP id eBHJkWZ09217
	for <linux-mm@kvack.org>; Sun, 17 Dec 2000 14:46:35 -0500 (EST)
Subject: memory use in 2.4.0-test12
From: Dan Christensen <jdc@julian.uwo.ca>
Date: 17 Dec 2000 14:44:37 -0500
Message-ID: <871yv67ryy.fsf@julian.uwo.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Please cc me in any reponses.]

I apologize if this is not the right list for this question.  Feel
free to direct me elsewhere.

I've noticed using test5 and test12 (the only two in the development
series that I've tried) that a lot of memory is being used that isn't
allocated to normal processes.  For example, below is the output of
top which shows all the processes I had running at that time (I had
killed most things).  Notice that mem used + swap used - buff - cached
is about 16M, even though if you add up the sizes of the processes you
get only 8M or so.  The output of free confirms this.  Is this normal?

Thanks,

Dan

This is with 2.4.0-test12 after running for about a day:

2:02pm  up 17:19,  1 user,  load average: 0.00, 0.02, 0.00
17 processes: 16 sleeping, 1 running, 0 zombie, 0 stopped
CPU states:   1.1% user,  87.2% system,   0.5% nice,  11.2% idle
Mem:  127320K av,  78360K used,  48960K free,      0K shrd,   1864K buff
Swap: 128516K av,    244K used, 128272K free                 60008K cached

 PID USER     PRI  NI  SIZE  RSS SHARE STAT  LIB %CPU %MEM   TIME COMMAND
    3 root      18   0     0    0     0 SW      0 94.7  0.0 891:41 kapm-idled
12802 root      12   0  1500 1500   756 R       0  0.9  1.1   0:00 top
    1 root       9   0   512  508   448 S       0  0.0  0.3   0:09 init
    2 root       9   0     0    0     0 SW      0  0.0  0.0   0:00 keventd
    4 root       9   0     0    0     0 SW      0  0.0  0.0   0:08 kswapd
    5 root       9   0     0    0     0 SW      0  0.0  0.0   0:00 kreclaimd
    6 root       9   0     0    0     0 SW      0  0.0  0.0   0:01 bdflush
    7 root       9   0     0    0     0 SW      0  0.0  0.0   0:03 kupdate
  161 root       9   0   744  744   616 S       0  0.0  0.5   0:03 syslogd
  163 root       9   0  1032 1028   436 S       0  0.0  0.8   0:00 klogd
  351 root      10   0  1420 1420  1064 S       0  0.0  1.1   0:00 bash
12784 root       9   0   480  480   420 S       0  0.0  0.3   0:00 getty
12785 root       9   0   480  480   420 S       0  0.0  0.3   0:00 getty
12786 root       9   0   480  480   420 S       0  0.0  0.3   0:00 getty
12787 root       9   0   480  480   420 S       0  0.0  0.3   0:00 getty
12788 root       9   0   480  480   420 S       0  0.0  0.3   0:00 getty
12803 root      10   0   644  644   524 S       0  0.0  0.5   0:00 less

free:
             total       used       free     shared    buffers     cached
Mem:        127320      77552      49768          0       1864      60012
-/+ buffers/cache:      15676     111644
Swap:       128516        244     128272
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
