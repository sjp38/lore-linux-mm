Message-ID: <40377BBD.6000301@movaris.com>
Date: Sat, 21 Feb 2004 07:39:41 -0800
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
References: <40363778.20900@movaris.com> <40368E00.3000505@cyberone.com.au>
In-Reply-To: <40368E00.3000505@cyberone.com.au>
Content-Type: multipart/mixed;
 boundary="------------040200000404090008060905"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: kernelnewbies <kernelnewbies@nl.linux.org>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040200000404090008060905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

> Can you post vmstat 1 logs for each kernel?

Attached is the vmstat output. The CPU stats are pretty interesting.

Kirk

--------------040200000404090008060905
Content-Type: text/plain;
 name="vmstatcombined.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmstatcombined.txt"

2.4.20:

procs               memory             swap          io     system             cpu
 r  b    swpd    free  buff  cache  si     so   bi     bo   in    cs  us  sy wa   id
 0  0       0  886312  8612  66152   0      0    0      0  109    88   1   0  0   99
 0  0       0  886312  8612  66152   0      0    0      0  132   140   1   0  0   99
 2  0    1016    5272  4212  28188   0    368   36    368  115   380  13  65  0   22
 1  0   45116    5236  4192  27872   0  40912    4  40912  724  1889   0  22  0   78
 1  1   76604    5236  4192  27872   0  30912    0  31004  646  1416   0  17  0   83
 0  2  112316    5236  4200  27872   0  36876   12  36872  675   873   0  14  0   86
 0  0    3560  930120  4192  27872   0  21536    8  21540  492   487   1  13  0   86
 0  0    3304  930372  4192  27876   0      0    0      0  124    45   0   0  0  100
 0  0    3304  930372  4192  27876   0      0    0      0  107    24   0   0  0  100



2.6.3:

procs               memory               swap         io         system         cpu
 r   b    swpd    free  buff cache    si     so    bi     bo     in   cs  us  sy   wa  id
 0   0   41884  862460  752  11916     0      0     0      0   1008   67   0   0    0 100
 1   0   41884  692660  756  11912     0      0     0      0   1028  115   9  38    0  53
 1   0   41884  254580  756  11912     0      0     0      0   1003   15   3  97    0   0
 0  12   52536    4148  128   2232  1124  74012  2128  74184  16321  930   2  60   38   0
 4  11  112492    4104  152   2460   180   1856   332   1856   5281   23   0   0  100   0
 4  11  131836    4936  152   2728   600  19344  1084  19348   5782  196   0  32   68   0
 6   8  151528    4512  172   2624   388  19692   672  19704   5650  134   0  33   67   0
 3  10  172484    4688  176   3056   436  20956  1188  20960   5718  200   0  30   70   0
 4  10  191760    4448  176   3036   220  19276   668  19288   5533  135   0  53   47   0
 5  11  212456    4580  180   3056   416  20696   960  20704   5656  155   0  33   67   0
 4  10  231376    4256  180   3176   124  18920   488  18924   5429  145   7  50   43   0
 0   7   41996  880800  208   4340   496    124  1740    136   1177  174   0  28   72   0
 0   4   41996  878752  216   5608   900      0  2180      0   1092  164   0   2   98   0
 0   4   41996  876576  224   6880   896      0  2192      0   1094  174   0   0  100   0
 0   2   41996  874280  236   8032  1148      0  2308      0   1138  241   0   2   98   0
 0   3   41996  871976  248   9220  1044      0  2236      4   1121  226   0   2   98   0
 0   0   41996  870696  264   9728   768      0  1284     48   1074  161   7   1   39  52
 0   0   41996  870696  264   9728     0      0     0      0   1024   42   0   0    0 100
 0   0   41996  870700  264   9728     0      0     0      0   1003   17   0   0    0 100
 0   0   41996  870700  264   9728     0      0     0      0   1023   40   0   0    0 100



--------------040200000404090008060905--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
