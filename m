From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 15:47:30 +1000 (EST)
Subject: PTI: LMbench results
In-Reply-To: <Pine.LNX.4.61.0505211541170.8979@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211546090.8979@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211417450.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211455390.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211500180.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211506080.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211513270.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211525500.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211541170.8979@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Processor, Processes - times in microseconds - smaller is better
----------------------------------------------------------------
                                  null     null                       open 
signal   signal    fork    execve  /bin/sh
kernel                           call      I/O     stat    fstat    close 
install   handle  process  process  process
-----------------------------  -------  -------  -------  -------  ------- 
-------  -------  -------  -------  -------
2.6.12-rc4                       0.316  0.45743    2.184    0.591    3.586 
0.587    2.915    115.0    684.8   3449.7
   s.d. (5 runs)                  0.000  0.00152    0.006    0.002    0.017 
0.000    0.019      0.0     13.8      9.4
2.6.13-rc4pti                    0.316  0.45813    2.198    0.588    3.509 
0.608    2.832    120.1    678.0   3475.1
   s.d. (5 runs)                  0.000  0.00014    0.020    0.001    0.020 
0.001    0.037      0.0     11.7     19.2

File select - times in microseconds - smaller is better
-------------------------------------------------------
                                 select   select   select   select   select 
select   select   select
kernel                           10 fd   100 fd   250 fd   500 fd   10 tcp 
100 tcp  250 tcp  500 tcp
-----------------------------  -------  -------  -------  -------  ------- 
-------  -------  -------
2.6.12-rc4                       1.999   11.546   27.426   53.804    2.798 
19.1855  46.4584  91.8376
   s.d.                           0.004    0.004    0.013    0.019    0.005 
0.00785  0.01316  0.03462
2.6.13-rc4pti                    2.030   11.571   27.445   53.788    2.791 
19.1657  46.4454  91.7666
   s.d.                           0.003    0.008    0.010    0.026    0.004 
0.01685  0.03803  0.05652

Context switching with 0K - times in microseconds - smaller is better
---------------------------------------------------------------------
                                 2proc/0k   4proc/0k   8proc/0k  16proc/0k 
32proc/0k  64proc/0k  96proc/0k
kernel                         ctx swtch  ctx swtch  ctx swtch  ctx swtch 
ctx swtch  ctx swtch  ctx swtch
-----------------------------  ---------  ---------  ---------  --------- 
---------  ---------  ---------
2.6.12-rc4                        13.136     13.788     11.394      8.872 
8.632     10.442     11.396
   s.d.                             5.930      3.110      1.692      1.773 
0.841      0.885      0.630
2.6.13-rc4pti                     13.082     14.514     11.336     10.090 
8.666      9.996     10.662
   s.d.                             6.000      2.952      1.688      0.860 
0.897      0.888      0.552

Context switching with 4K - times in microseconds - smaller is better
---------------------------------------------------------------------
                                 2proc/4k   4proc/4k   8proc/4k  16proc/4k 
32proc/4k  64proc/4k  96proc/4k
kernel                         ctx swtch  ctx swtch  ctx swtch  ctx swtch 
ctx swtch  ctx swtch  ctx swtch
-----------------------------  ---------  ---------  ---------  --------- 
---------  ---------  ---------
2.6.12-rc4                        13.674     12.524      9.546     10.002 
10.194     12.810     14.578
   s.d.                             5.878      3.668      2.670      0.701 
1.029      0.414      0.381
2.6.13-rc4pti                     13.558     13.780     10.098     10.220 
9.662     12.934     14.600
   s.d.                             6.133      3.618      2.449      0.034 
0.854      0.646      0.560

Context switching with 8K - times in microseconds - smaller is better
---------------------------------------------------------------------
                                 2proc/8k   4proc/8k   8proc/8k  16proc/8k 
32proc/8k  64proc/8k  96proc/8k
kernel                         ctx swtch  ctx swtch  ctx swtch  ctx swtch 
ctx swtch  ctx swtch  ctx swtch
-----------------------------  ---------  ---------  ---------  --------- 
---------  ---------  ---------
2.6.12-rc4                        11.450     14.246     10.588      9.480 
9.898     13.528     17.054
   s.d.                             7.310      3.511      2.347      0.850 
1.259      0.680      0.762
2.6.13-rc4pti                     16.656     12.896      9.896      9.240 
10.658     13.844     17.104
   s.d.                             0.143      3.537      1.382      1.511 
1.918      0.856      0.691

Context switching with 16K - times in microseconds - smaller is better
----------------------------------------------------------------------
                                2proc/16k  4proc/16k  8proc/16k  16prc/16k 
32prc/16k  64prc/16k  96prc/16k
kernel                         ctx swtch  ctx swtch  ctx swtch  ctx swtch 
ctx swtch  ctx swtch  ctx swtch
-----------------------------  ---------  ---------  ---------  --------- 
---------  ---------  ---------
2.6.12-rc4                        17.688     13.784     11.712     10.436 
11.328     17.222     21.424
   s.d.                             0.008      3.579      2.312      1.745 
1.733      1.403      1.394
2.6.13-rc4pti                     17.672     13.818     10.966     11.194 
13.000     17.180     21.148
   s.d.                             0.049      3.665      1.315      0.799 
0.875      0.631      0.873

Context switching with 32K - times in microseconds - smaller is better
----------------------------------------------------------------------
                                2proc/32k  4proc/32k  8proc/32k  16prc/32k 
32prc/32k  64prc/32k  96prc/32k
kernel                         ctx swtch  ctx swtch  ctx swtch  ctx swtch 
ctx swtch  ctx swtch  ctx swtch
-----------------------------  ---------  ---------  ---------  --------- 
---------  ---------  ---------
2.6.12-rc4                        19.474     15.790     14.398     13.948 
17.786     30.478     43.438
   s.d.                             0.265      3.501      1.524      1.454 
1.028      1.713      0.980
2.6.13-rc4pti                     19.394     15.678     11.830     13.026 
17.366     32.206     43.038
   s.d.                             0.103      3.589      1.988      1.914 
2.064      2.087      1.551

Context switching with 64K - times in microseconds - smaller is better
----------------------------------------------------------------------
                                2proc/64k  4proc/64k  8proc/64k  16prc/64k 
32prc/64k  64prc/64k  96prc/64k
kernel                         ctx swtch  ctx swtch  ctx swtch  ctx swtch 
ctx swtch  ctx swtch  ctx swtch
-----------------------------  ---------  ---------  ---------  --------- 
---------  ---------  ---------
2.6.12-rc4                        20.930     18.720     18.142     20.558 
46.034     80.218     86.914
   s.d.                             2.754      2.992      1.737      1.393 
4.058      1.774      2.466
2.6.13-rc4pti                     22.596     21.158     20.558     29.526 
51.312     81.384     88.340
   s.d.                             0.185      3.291      1.060      8.992 
4.053      2.880      3.548

File create/delete and VM system latencies in microseconds - smaller is 
better
----------------------------------------------------------------------------
                                  0K       0K       1K       1K       4K 
4K      10K      10K     Mmap     Prot    Page
kernel                         Create   Delete   Create   Delete   Create 
Delete   Create   Delete   Latency  Fault   Fault
------------------------------ -------  -------  -------  -------  ------- 
-------  -------  -------  -------  ------  ------
2.6.12-rc4                       44.78    16.93    64.39    31.40    64.48 
31.37    83.36    34.13   2173.6   1.087    1.00
   s.d.                            0.05     0.07     0.06     0.08     0.20 
0.15     0.07     0.03     15.9   0.021    0.00
2.6.13-rc4pti                    44.71    16.94    64.53    31.49    64.77 
31.44    84.07    34.19   2306.4   1.173    1.00
   s.d.                            0.03     0.04     0.07     0.07     0.18 
0.16     1.03     0.03     15.6   0.018    0.00

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
kernel                           Pipe   AF/Unix     UDP   RPC/UDP     TCP 
RPC/TCP  TCPconn
-----------------------------  -------  -------  -------  -------  ------- 
-------  -------
2.6.12-rc4                     164.930   80.218   87.183  53.8829  70.5775 
88.0925   50.104
   s.d.                           7.174    2.140  39.9387  0.66410  29.6098 
22.7606    0.247
2.6.13-rc4pti                  156.261   80.508  73.4638  53.9942  60.9479 
71.4832   50.257
   s.d.                          11.973    2.678  38.7197  0.63384  24.5805 
18.2365    0.261

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
                                                              File     Mmap 
Bcopy    Bcopy   Memory   Memory
kernel                           Pipe   AF/Unix    TCP     reread   reread 
(libc)   (hand)     read    write
-----------------------------  -------  -------  -------  -------  ------- 
-------  -------  -------  -------
2.6.12-rc4                     1250.44  1729.22  1240.64  1102.10   590.12 
660.54   387.10   589.91   556.02
   s.d.                            5.43   267.98     4.80     1.52     0.48 
2.09     0.52     0.50     2.66
2.6.13-rc4pti                  1070.91  1770.60  1245.81  1102.00   589.94 
660.65   387.23   590.16   555.78
   s.d.                          301.43   124.01     5.33     1.79     0.44 
2.52     0.58     0.42     2.80

*Local* More Communication bandwidths in MB/s - bigger is better
----------------------------------------------------------------
                                   File     Mmap  Aligned  Partial  Partial 
Partial  Partial
OS                                open     open    Bcopy    Bcopy     Mmap 
Mmap     Mmap    Bzero
                                  close    close   (libc)   (hand)     read 
write   rd/wrt     copy     HTTP
-----------------------------  -------  -------  -------  -------  ------- 
-------  -------  -------  -------
2.6.12-rc4                     1102.20   558.53   664.23   677.96   772.99 
1529.92   473.22  2345.51   16.256
   s.d.                            1.71     0.66     2.47     2.49     0.53 
32.52     0.51     9.35    0.412
2.6.13-rc4pti                  1102.76   557.95   669.52   677.41   773.41 
1521.63   473.11  2344.87   16.152
   s.d.                            0.54     0.18     9.33     3.27     0.54 
33.58     0.60    11.55    0.151

Memory latencies in nanoseconds - smaller is better
---------------------------------------------------
kernel                          Mhz     L1 $     L2 $    Main mem
-----------------------------  -----  -------  -------  ---------
2.6.12-rc4                       900    2.227    6.686     121.45
   s.d.                             0    0.412    0.412       0.41
2.6.13-rc4pti                    900    2.227    6.686     121.44
   s.d.                             0    0.151    0.151       0.15

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
