Received: from localhost (kervel@localhost)
	by bakvis.kotnet.org (8.9.3/8.9.3) with ESMTP id XAA02257
	for <linux-mm@kvack.org>; Sat, 10 Feb 2001 23:26:05 +0100
Date: Sat, 10 Feb 2001 23:26:04 +0100 (CET)
From: Frank Dekervel <kervel@bakvis.kotnet.org>
Subject: behaviour with 2.4.1-vmpatch
Message-ID: <Pine.LNX.4.21.0102102308170.1884-100000@bakvis.kotnet.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

since i run 2.4.1-vmpatch, my system regulary stops responding for 2
or more seconds, and it seems to swap in/out heavily.
This is really easy to reproduce for me, just starting a memory hog, so
swap is touched, and i was unable to reproduce this behaviour on 2.4.0.

also, i found this in my syslog:
Feb  9 01:57:31 bakvis kernel: __alloc_pages: 3-order allocation failed.
Feb  9 01:57:31 bakvis kernel: __alloc_pages: 2-order allocation failed.
Feb  9 01:57:31 bakvis kernel: __alloc_pages: 3-order allocation failed.
Feb  9 01:57:31 bakvis last message repeated 209 times
(note 100+ such messages in the same minute)


(and much more of this). i cannot exactly remember what i was doing then,
but i think it was stressing the system with make -j2 or memory consuming
programs like Xfree ...)
i couldnot reproduce it today.

here some sample vmstat output:
   procs                      memory    swap          io     system
cpu
  r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us
sy  id
 
 1  1  0  68076   1864   4100  79204   2 198    10   109  522  1351   5
6  88
 1  5  0  70056   1688   4128  79492  42 668   548   241  852  2432  19
4  76
 3  2  0  69116   1544   3936  78848  20 266   309   102  340   754  16
4  80
 0  5  0  68940   1468   3952  78932   4 1328    95   355  828   727   3
2  9
 1  3  0  67196   1944   4044  77376 260  54   134    31  311   600  29
2  69
 0  4  0  66724   1628   4064  78160   0 530   320   151  314   322  18
2  80
 3  0  0  66360   1464   4072  77904  56 432   142   131  322   460  11
3  85
 2  1  2  67632   1484   4072  79392  26 1076    74   306  636   399   1
2  9
 2  2  0  68012   1464   4000  80108  86 1084   168   294  469   445   6
2  9


greetings,

Frank Dekervel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
