From: Michal Ostrowski <mostrows@styx.uwaterloo.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14650.50266.280696.578972@styx.uwaterloo.ca>
Date: Sun, 4 Jun 2000 17:04:26 -0400 (EDT)
Subject: Good I/O Performance with 2.4.0-test1-ac7 + axboe
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here are some new tests I've re-run with my code using Jens Axboe's
elevator fixes.  Looks pretty good.  I'll try running SMP tests today
or tomorrow.

Note the order of magnitude improvement from the test results I posted 
last week.

Small downside --- system is much less responsive to user interaction
during heavy I/O.

Michal Ostrowski
mostrows@styx.uwaterloo.ca


Threads	 Blocks	    Time
	 per read

1	 1		7.25
1	 2		7.03
1	 4		8.25
1	 8		14.46
1	 16		19.72
1	 32		22.98

4	 1		9.49			
4	 2		9.27
4	 4		8.00
4	 8		9.16
4	 16		16.17
4	 32		22.14

8	 1		6.95
8	 2		6.31
8	 4		6.88
8	 8		8.92
8	 16		15.76
8	 32		22.14

16	 1		5.62
16	 2		5.91
16	 4		6.90
16	 8		8.09
16	 16		14.92
16	 32		22.69

32	 1		5.05
32	 2		5.14
32	 4		5.81
32	 8		7.55
32	 16		15.22
32	 32		20.13

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
