Received: (from msimons@localhost)
	by moria.simons-clan.com (8.10.0/8.10.0) id e4FNEUP05749
	for linux-mm@kvack.org; Mon, 15 May 2000 19:14:30 -0400
Date: Mon, 15 May 2000 19:14:30 -0400
From: Mike Simons <msimons@moria.simons-clan.com>
Subject: 2.3.99-pre8 + riel patch 2, results.
Message-ID: <20000515191430.A5677@moria.simons-clan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all,

  This info plus the exact patches used are available at:
http://moria.simons-clan.com/~msimons/


2.3.99-pre8 plus "riel-patch2.diff"
===================================

  vmstat 1 | tee log ... running in one window.
  mmap002            ... running in another window.

  All tests done in multi-user console mode with nothing else happening.

  First run the cache fills up... swpd starts up.  Two seconds after swpd
mmap002 gets killed.  The wierd-ish thing is vmstat shows only "bi" up 
until the time swap started...
  - why wasn't there any bo?

  The system becomes very unresponsive just _after_ killing mmap002.
then the machine lags badly for about 6 seconds (which show up as three
vmstat lines) until that point things were fine and after that it's fine.

  I can run mmap002 a few more times... but now that the cache is full
the system will kill mmap002 very quickly...

  Second run it takes 7 seconds to kill mmap002. 
  Third run takes 4 seconds to kill mmap002, and 2 seconds later init dies.   


  The wierd part is that when init dies the whole system is locked... not 
even caps-lock light works.  In the past (2.2.*) when init was killed
the system would continue to function for at least several minutes when
very little else was happening.

  A few times the system kills a whole list of processes before locking:
killing process mmap002, klogd, init, init, sysklogd, sysklogd,
vmstat, bash, tee, bash, init, init, init, then _solid_ hang... 
This within seconds of starting of the third mmap002 run.

    Hope that helps,
      Mike Simons

first run of mmap002
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0  16340  85212   8516   0   0  1677     3  294   384   4   4  92
 0  0  0      0  16316  85212   8520   0   0     0     0  108     9   1   0  99
 0  0  0      0  16316  85212   8520   0   0     0     0  106    15   0   0 100
 0  0  0      0  16312  85216   8520   0   0     1     0  109    15   0   0 100
 0  0  0      0  16304  85216   8520   0   0     0     0  107    13   0   0 100
 0  0  0      0  16304  85216   8520   0   0     0     0  105    11   0   0 100
 0  0  0      0  16304  85216   8520   0   0     0    27  124    11   0   0 100
 0  1  0      0  16220  85216   8524   0   0     1     0  102    12   0   0 100
 0  1  0      0  15712  76436  18608   0   0  2646     0  350   433   3   2  95
 1  0  0      0  14976  71420  24816   0   0  1554     0  206   212   4   3  93
 1  0  0      0  15056  65536  31152   0   0  1585     0  204   216   5   2  93
 0  1  0      0  14484  60552  37168   0   0  1506     0  199   209   2   1  97
 1  0  0      0  14572  54732  43440   0   0  1569     0  202   212   5   4  91
 0  1  0      0   9320  53588  49776   0   0  1586     0  340   482   3   0  97
 0  1  0      0   2836  53592  56048   0   0  1569     0  258   318   4   0  96
 1  0  0      0  19924  32896  62128   0   0  1522     0  200   204   3   7  90
 0  1  0      0  13368  32900  68464   0   0  1585     0  205   211   1   2  97
 1  0  0      0   7016  32908  74608   0   0  1538     0  224   206   2   1  97
 0  1  0      0   2464  31248  80816   0   0  1553     0  204   209   1   4  95
 1  0  0      0  31904    220  86316   0   0  1394     4  212   203   3   7  90
 1  0  0      0  25932    248  92076   0   0  1447     0  207   213   1   2  97
 1  2  0      0  19888    344  97732   0   0  1438     0  218   222   6   0  94
 1  0  0      0  14000    376 103492   0   0  1448     0  218   207   5   0  95
 1  0  0      0   7848    380 109444   0   0  1489     0  197   196   6   1  93
 0  1  0      0   2900    308 114452   0   0  1426     7  322   375   4   2  94
 1  0  1    112   3180     72 117816   0 112  1042    61  336   375   3  13  84
 2  0  0    112   3056     68 118032   0   0  1157   146  487   645   4   6  90
 0  1  0    720   2120     96 119648   0 608   891   322  464   375   3  18  79
VM: killing process mmap002
 0  1  1    936   2668     72 119360 112 264   499  1102  449   119   0  39  61
 1  1  1   1368   2216    120 119536   8 436    60 12818 7676 13356   0   7  93
 0  2  0   1672   2576    116 120104 320 312   248 15210 7575 11462   0   9  91
 0  0  0   1672   2424    124 120236  28   0    35     0  268   338   0   0 100
 0  0  0   1672   2424    124 120236   0   0     0     0  520   845   0   0 100
 0  0  0   1672   2424    124 120236   0   0     0     0  300   405   0   0 100
 0  0  0   1672   2424    124 120236   0   0     0     0  132    10   0   0 100
 0  0  0   1672   2424    124 120236   0   0     0     0  132     8   0   0 100
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
   procs                      memory    swap          io     system         cpu

second run of mmap002
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0   1660   3820    472 118200   1   2   341    40  163   120   1   1  98
 0  0  0   1660   3808    480 118204   0   0     2     0  112    13   0   0 100
 0  0  0   1660   3808    480 118204   0   0     0     0  103     7   0   0 100
 0  1  0   1528   2772    432 119100   0   0   917     3  186   165  17   5  78
 1  0  0   1464   3084    136 119068   0   0   846    12  178   141  38   6  56
 1  0  0   1600   1824     76 120664  12 136  1006   101  212   166   7   6  87
 0  1  3   1592   1324    124 119824 168  36   320  2154  411   330   0  19  81
VM: killing process mmap002
 0  2  1   1904   2460    148 118564 156 324   188 17503 9158 16378   0   7  93
 0  1  0   1884   2200    176 118760  76   0    61  4565  638   759   0   2  98
 0  0  0   1884   2196    176 118760   0   0     0     0  625   834   0   1  99
 0  0  0   1884   2188    180 118760   0   0     1     0  538   876   0   1  99
 0  0  0   1884   2188    180 118760   0   0     0     0  269   345   0   0 100
 0  0  0   1884   2188    180 118760   0   0     0     0  123    10   0   0 100
 0  0  0   1884   2188    180 118760   0   0     0     0  132     8   0   0 100

third run of mmap002
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0   1868   2832    272 117968   2   3   327    74  174   139   1   1  98
 0  0  0   1868   2800    276 117972   0   0     1     0  131    51   0   0 100
 1  0  0   1904   2540    292 118104   0  36   484    10  156    95  32   9  59
 1  0  0   1812   3572    128 118864   0  36  1004    24  207   170  25  10  65
 0  1  1   2780   1380    100 121416 484 1016  1101  3432  797   392   1  20  79
 0  1  1   3056   2228     92 121160 340 340   109  8295 6189 11292   0  10  90
[...death of system... I'm surprised this made it to disk...]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
