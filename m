Received: from localhost (kervel@localhost)
	by bakvis.kotnet.org (8.9.3/8.9.3) with ESMTP id SAA22040
	for <linux-mm@kvack.org>; Thu, 22 Feb 2001 18:19:51 +0100
Date: Thu, 22 Feb 2001 18:19:48 +0100 (CET)
From: Frank Dekervel <kervel@bakvis.kotnet.org>
Subject: linux 2.4.1-ac20 problems
Message-ID: <Pine.LNX.4.21.0102221803430.22007-100000@bakvis.kotnet.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

i have some problems with 2.4.1-ac20 vm.
'free' output is really strange compared to 2.4.2-pre2
             total       used       free     shared    buffers     cached
Mem:        126628     124072       2556          0       1516     101836
-/+ buffers/cache:      20720     105908
Swap:       259384     171804      87580

i am running a java IDE taking 107 meg ram, kde II and a browser,
having 128 meg of ram. i already added a swapfile twice 
(with dd, mkswap and swapon) because i only had 130 meg swap.
It also took really long to swap my IDE back in after running an xterm
(long = 30-60 seconds)
(and no, it was not java gc'ing)

below: when swapping my ide back in memory after running an xterm.

vmstat 2 | tee vmout

   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 2  0  0 172248   1480   1604 104084  14  14    15     4  238   414   2   1  96
 1  0  0 172248   1480   1620 104004   2   0    37     0  445  1727   2   4  94

now it starts

 0  1  0 172048   1480   1684 103688 652 146   195    54  598  1617   9   3  88
 3  1  0 172272   1464   1668 104348 1714 322   492    82  577  1031   4  11  85
 2  1  0 171580   1464   1628 103208 1454 250   406    64  627  1319   9   6  84
 2  0  0 173112   1480   1632 104248 470 274   181    71  501  1571   8  28  64
 4  0  0 173376   4292   1612 101916 938 506   240   127  719  1533  10  21  69
 2  0  0 173476   3796   1532 102472 1104 446   276   114  703  1653  10   9  81
 2  0  0 173500   1464   1532 104668 2050 128   513    35  575  1146   6   6  88
 4  0  0 173488   1468   1420 104572 1562  66   431    17  626  1777   8   5  87
 4  0  0 173908   1484   1276 105080 1650 220   436    58  716  1507   9   9  82
 4  0  0 173720   1472   1252 104932 1994   2   506     2  577  1636   6   6  88
 4  0  0 173208   1684   1120 104248 2114 120   529    32  616  2012  23   5  72
 2  0  0 173104   1704   1088 104076 1824 154   488    41  668  1808  16  10  73
 3  0  0 173752   1472   1020 105004 1766 152   442    40  698  1201   5   9  85
 3  0  0 174000   1484    900 105456 1680 264   420    67  554   773   2   9  90
 1  0  0 173348   1468    684 104472 6234 1532  1599   389 2481  5178   1   2  96
 6  0  0 173344   1468    616 104432 1514 618   411   158  681  1891   4   6  90
 1  1  0 173404   1464    496 104480 1812 440   471   113  862  1649   2   3  95
 2  0  0 174600   1472    400 105856 5030 2074  1432   523 2635  5324   1   7  92
 2  0  0 174356   1464    376 105160 2738 642   728   169 1185  2510   1   3  96
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 2  0  0 174392   1468    380 104348 1242 352   311    91  805  1411   3  11  86
 2  1  0 174612   1468    384 103428 1558 642   536   165  629  1076   2   6  92
 3  0  0 174700   1472    380 102664 1064 568   266   142  431   671   1   5  94
 2  0  0 175156   1464    332 102536 1578 886   395   222  856  1499   3   8  89
 2  2  0 175060   1464    324 102408 872 468   273   120  460   991   1   2  97
 1  0  0 174804   1472    324 102248 1156 572   289   145  554   932   0   3  97
 1  0  0 174700   1468    316 101904 1274 438   319   110  573   962   0   4  96
 2  0  0 174576   1464    316 100792 830 348   208    90  491   808   2   2  96
 2  0  0 174868   1468    316 100036 1022 236   288    63  548   941   0   2  98
 1  0  0 175604   1464    308  99684 2514 830   629   210 1083  1608   0   8  92
 1  0  0 175632   1464    320  97432 1204 276   335    73  555   871   1   8  91
 1  0  0 175356   1464    324  97272 1462   8   373     5  504  1003   3   3  94
 1  0  0 175520   1464    300  92392 1176 404   294   105  569   985   1   9  90
 1  1  0 175260   1464    308  91940 896 608   327   156  665  1212   1   3  96
 2  0  0 174384   1464    284  91748 1896  92   474    26  473  1882   6   8  86
 2  0  1 172952   1464    288  91208 1500 634   424   163  722  1437   2   4  94
 1  0  0 171892   1608    292  90568 1940   0   546     0  394   706   4   3  92
 2  0  0 169988   1464    276  90444 1796   0   449     0  405   733  10   4  86
 3  0  0 169024   1464    276  89940 1136  80   284    23  383   846  34   1  65
 1  0  0 169704   1464    268  91592 1288 448   344   112  565   984   5   4  92
 5  0  0 168612   1468    272  91764 1006   0   294     0  518  1158  13   3  84
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0 169420   1472    276  93016 396 336   100    84  400   697   9   3  88
 4  1  4 172888   1468    288  97044 1026 126   268    32  447   721   5  24  71
11  0  4 175644   1464    296 100596 1740 268   468    79  572   966   5  41  54
 2  0  0 174968   4256    292  98884  30   0     8     0  285   654   2   2  95
 2  0  0 174968   4256    292  98884   0   0     0     0  281   609   0   0 100


now it's done.

greetings,

Frank Dekervel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
