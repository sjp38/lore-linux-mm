Content-Type: text/plain;
  charset="iso-8859-1"
From: Steven Cole <elenstev@mesatop.com>
Reply-To: elenstev@mesatop.com
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Sun, 29 Jul 2001 11:48:30 -0600
References: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva> <01072822131300.00315@starship>
In-Reply-To: <01072822131300.00315@starship>
MIME-Version: 1.0
Message-Id: <01072911483000.01366@localhost.localdomain>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>, Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, "Mike Galbraith <mikeg@wen-online.de> Roger Larsson" <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Saturday 28 July 2001 14:13, Daniel Phillips wrote:
[snippage]
> Oh, by the way, my suspicions about the flakiness of dbench as a
> benchmark were confirmed: under X, having been running various memory
> hungry applications for a while, dbench on vanilla 2.4.7 turned in a 7%
> better performance (with a distinctly different process termination
> pattern) than in text mode after a clean reboot.
>

>From the FWIW department, apologies in advance if this is all moot.

Here are the results of nine runs of dbench 32.  I ran vmstat before and after
each instance of running time  ./dbench 32.  These verbose results are provided
after the following summary.  The test machine is a PIII 450, 384MB, ReiserFS on
all partitions, disks IDE. Tests were all run from an xterm and KDE2.

Steven


2.4.8-pre2 	After running 8 hours
Run #1	Throughput 5.77702 MB/sec
Run #2	Throughput 5.8781 MB/sec
Run #3	Throughput 6.08052 MB/sec

2.4.8-pre2 	After fresh reboot
Run #4	Throughput 7.18107 MB/sec
Run #5	Throughput 7.0096 MB/sec
Run #6	Throughput 7.1165 MB/sec

2.4.7      	After fresh reboot
Run #7	Throughput 8.96163 MB/sec
Run #8	Throughput 9.20907 MB/sec
Run #9	Throughput 9.88017 MB/sec

-------------------------------------------------------------------------------
2.4.8-pre2 	After running 8 hours
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  0  0  26272  31248  12100  63688   2   1    49   185  580   158   2   7  91

[....snipped]
Throughput 5.77702 MB/sec (NB=7.22127 MB/sec  57.7702 MBit/sec)
34.70user 426.52system 12:11.28elapsed 63%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0  26120 130808   5656  11236   2   1    53   249  716   156   2   9  89

[....snipped]
Throughput 5.8781 MB/sec (NB=7.34763 MB/sec  58.781 MBit/sec)
34.55user 439.76system 11:59.61elapsed 65%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0  26120 130200   5152  11884   2   1    56   310  844   154   2  11  87

[....snipped]
Throughput 6.08052 MB/sec (NB=7.60065 MB/sec  60.8052 MBit/sec)
34.36user 409.73system 11:35.69elapsed 63%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  0  0  26120 144324   4888  12024   2   1    59   366  962   153   2  13  86


-------------------------------------------------------------------------------
2.4.8-pre2 	After fresh reboot
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0 278468   9152  56208   0   0   296   118  950   248  13  15  73

[....snipped]
Throughput 7.18107 MB/sec (NB=8.97633 MB/sec  71.8107 MBit/sec)
34.35user 348.11system 9:48.24elapsed 65%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0 287192  13064  34696   0   0   167  2090 4619   125   8  69  23

[....snipped]
Throughput 7.0096 MB/sec (NB=8.762 MB/sec  70.096 MBit/sec)
33.05user 348.67system 10:03.62elapsed 63%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0 285804  14440  34700   0   0   145  2368 5128   107   7  76  17

[....snipped]
Throughput 7.1165 MB/sec (NB=8.89563 MB/sec  71.165 MBit/sec)
34.67user 352.81system 9:54.57elapsed 65%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0 285192  15152  34700   0   0   136  2475 5324   101   7  79  14


-------------------------------------------------------------------------------
2.4.7      	After fresh reboot
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  0  0      0 278356   9288  56176   0   0   293   117  941   238  13  15  73

[....snipped]
Throughput 8.96163 MB/sec (NB=11.202 MB/sec  89.6163 MBit/sec)
33.91user 244.57system 7:52.40elapsed 58%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0 309540   5808  22792   0   0   193  1761 4013   133   9  64  27

[....snipped]
Throughput 9.20907 MB/sec (NB=11.5113 MB/sec  92.0907 MBit/sec)
34.43user 255.59system 7:39.69elapsed 63%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0 310780   5796  21920   0   0   175  2028 4511   113   9  72  19

[....snipped]
Throughput 9.88017 MB/sec (NB=12.3502 MB/sec  98.8017 MBit/sec)
33.30user 248.82system 7:08.54elapsed 65%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (1008major+1402minor)pagefaults 0swaps
   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0      0 311180   5356  22024   0   0   172  2124 4694   107   8  76  16
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
