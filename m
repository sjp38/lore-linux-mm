Date: Mon, 18 Sep 2000 11:31:31 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: [torriem@cs.byu.edu: VM: do_try_to_free_pages failed in 2.2.17]
Message-ID: <20000918113131.J10210@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Michael L Torrie <torriem@cs.byu.edu>
List-ID: <linux-mm.kvack.org>

Hi all,

Yet another 2.2.17-eats-my-VM report.  Does anyone have proven patches
other than reverting completely to the old 2.2 VM?  There's been lots
of discussion and hypothesising but no silver bullets so far.

--Stephen

----- Forwarded message from Michael L Torrie <torriem@cs.byu.edu> -----

Date: Sat, 16 Sep 2000 23:11:51 -0600 (MDT)
From: Michael L Torrie <torriem@cs.byu.edu>
To: sct@redhat.com
Subject: VM: do_try_to_free_pages failed in 2.2.17

If you're not the right man to talk to, couldyou forward this onto the
kernel mailing list?  Your name was on the source code, so I guess you are
the person who wrote it, unless I have the wrong Steve Tweedie.  Forgive
me for not writing to the mailing list, but the traffic level prohibits my
subscribing.

In any case, On three separate occasions, on 2 different machines, I've
had the kernel report:
Sep 16 22:19:35 enterprise kernel: VM: do_try_to_free_pages failed for
sawfish..

and for many different programs.  Basically the kernel just spins out of
control and the whole machine locks up.  I understand this was a bug in
the 2.2.16 series, but thought it had been fixes in the 2.2.17 series.  I
need to report the bug is alive and well.  Programs that I know don't have
memory leaks (they've run fro months in the past) suddenly appear to be
consuming huge amounts of ram and swap until the machine thrashes to a
halt.  Perhaps the VM code cannot or does not release pages correctly.  It
appears that programs that do a lot of dynamic allocation will
suffer.  XMMS brought down the system in 15 minutes one time.

I've also had this happen on a server running the same processor with
Reiserfs.  I had to cold restart it.  From watching the system (It has 2
GB of ram and 2 GB of swap so it takes a few days to get to that point),
every once in a while, the kswapd will do some sort of massive swap, which
interrupts nfs service, and in fact all operation.  Is that normal?

If I need to be clearer or provide more information, please let me
know.  I'd appreciate if this problem would receive attention, as I want
my machine to stay up for more than several days, and I don't want to have
to reboot my server, ever.

thank you very much.

Michael Torrie
BYU CS System Programmer
----

----- End forwarded message -----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
