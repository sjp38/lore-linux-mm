Message-ID: <20000420210732.5417.qmail@web123.yahoomail.com>
Date: Thu, 20 Apr 2000 14:07:32 -0700 (PDT)
From: Cacophonix <cacophonix@yahoo.com>
Subject: swapping from pagecache?
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,
I've been running a few webserver tests with 2.3.99-pre6-2, and there seems 
to be some difference in behavior between 2.2.x and 2.3.99-pre.

Specifically, on 2.3.99, it appears that unused pages from the page cache
are swapped to disk, while in 2.2, unused pages are not swapped. As a result,
performance on 2.3.99-pre drops to below 2.2. levels under such a scenario.

For example, a procinfo on 2.3.99-pre6 reports:

Linux 2.3.99-pre6 (root@pc46) (gcc egcs-2.91.66) #8 Sun Apr 16 14:28:40 PDT
2000 1CPU [pc46]
 
Memory:      Total        Used        Free      Shared     Buffers      Cached
Mem:        513120      511220        1900           0        6280      442264
Swap:       265064       41984      223080
 
Bootup: Thu Apr 20 12:12:46 2000    Load average: 4.02 3.40 2.05 2/39 2287
 
user  :       0:00:01.40  14.0%  page in :     5191  disk 1:       62r     166w
nice  :       0:00:00.01   0.1%  page out:      904  disk 2:     1235r       0w
system:       0:00:04.65  46.5%  swap in :       72
idle  :       0:00:03.94  39.4%  swap out:      787
uptime:       0:31:28.18         context :     2421
 
irq  0:      1000 timer                 irq 10:      1817 sym53c8xx
irq  1:         0 keyboard              irq 11:        21 eth1
irq  2:         0 cascade [4]           irq 12:         0 PS/2 Mouse
irq  3:         0                       irq 13:         0 fpu
irq  4:         0                       irq 15:     54620 NetGear GA620 Gigabi
                                                                               
                          

Note that the value under shared is 0.

A procinfo under 2.2.16-pre1 with a similar scenario shows memory being
shared (mainly by the web server, which has an internal cache), and does
not swap at all.

Any comments on this behavior? (shm is mounted of course).  Thanks for 
any advice.

cheers,
karthik


__________________________________________________
Do You Yahoo!?
Send online invitations with Yahoo! Invites.
http://invites.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
