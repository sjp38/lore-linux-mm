Message-ID: <39183536.C0017DCA@ucla.edu>
Date: Tue, 09 May 2000 08:56:38 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: [DATAPOINT] pre7-8 swaps with FREE mem?
References: <Pine.LNX.4.10.10005081927200.839-100000@penguin.transmeta.com> <39178682.9AA1AB59@sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Quintela Carreira Juan J." <quintela@vexeta.dc.fi.udc.es>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have an UP PPro, 166 Mhz, 64MB RAM, IDE disk.

1. Pre7-8 swaps a lot.  Firstly, it swaps when I have 12Mb/64Mb memory
free. (just to clarify, I don't mean 'cache', I mean 'free') Secondly,
look at this:

telomere:~> free
             total       used       free     shared    buffers    
cached
Mem:         62780      61360       1420          0        412     
44804
-/+ buffers/cache:      16144      46636
Swap:       128484      38456      90028

The VM is definately balanced towards swapping out.  I'm only running
netscape, and emacs, (and gnome), so there should be minimal swap-out. 
I'm not sure the high swap usage is a result of a large cache, because
the high swap usage started BEFORE memory actually got tight.  So, may
the cache is just taking advantage of the nice, large free chunks of
memory :)

2. Pre7-8 swaps out things that should be left in.  It DOESN"T swap out
the running quake engine this time :)  However, it does swap out chunks
of netscape, while loading it, making it significantly slower. 
Basically, there is not need to do ANY page-in, but there is a
significant page-in rate when load netscape.  This implies that the
wrong pages are swapped out.  (Am I saying something stupid here??)  

RSS  SWAP  MAJFLT
8864 14032 26248 netscape
36   2656  78    xfs
4    2303  59    jserver
6780 2252  13508 X
2372 856   4739  emacs

netscape, emacs, and X should not have been swapped out.
xfs and jserver SHOULD be swapped out. (this is an improvement over
pre7-6)

3. Unlike pre7-6, which basically died, if I tried to run more than a
few programs, pre7-8 is more or less useable, although not perfect (as
in 2), because it DOES swap out unused code :) In can (not well :) run
netscape, mozilla, gimp, quake, and emacs in 64Mb RAM. There is no way
that pre7-6 could get this far.

telomere:~> free
             total       used       free     shared    buffers    
cached
Mem:         62780      61168       1612          0        348     
14992
-/+ buffers/cache:      45828      16952
Swap:       128484      39004      89480

telomere:~> vmstat 1
   procs                      memory    swap          io    
system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us 
sy  id
 1  0  0  38560   1484    256  14764  35  31   167    10  151   439 
58   9  33
 5  0  1  38560   1668    276  14664  20   0  3215     0  561   975  65 
35   0
 1  2  0  38560   1584    276  14636 556   0  1596     0  204   514  75 
24   1
 3  0  0  38560   1476    276  14732   0   0    97     0  152   456 
99   1   0
 3  2  0  38556   1536    172  14752 632   0  2902     9  499   850  52 
32  16
 4  0  1  38548   1564    164  14820 440   0   627     0  327   693  70 
28   2
 3  0  0  38540   1212    180  15152 216   0  1337     0  174   447  50 
42   9
 3  2  1  38620   1296    188  15160 1276  84   810    21  352   486 
56  44   0 1  2  0  38616   1248    188  15204 436   0   733     1 
242   465  67  33   0
 4  0  0  38616   1208    192  15244 112   0   345     0  197   535  84 
16   0
 4  0  0  38616   1336    196  15120 196   0   244     0  232   516  69 
21  10
 3  0  0  38616   1192    196  15244  56   0    83     0  172   573 
97   1   2
 3  0  0  38616   1568    196  14916   4   0    53     2  211   548  81 
19   0
 2  0  0  38616   1516    204  14960  36   0   535     0  198   493  86 
14   0
 4  0  0  38616   1224    204  15252 176   0   159     0  184   479 
92   6   2
 4  0  1  38616   1320    216  15164  52   0  1291     0  186   483  79 
21   0

</datapoint>
-BenRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
