Subject: Re: [PATCH] 2.4.20-rmap15a
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com>
	<6usmxfys45.fsf@zork.zork.net> <20021203195854.GA6709@zork.net>
	<30200000.1038946087@titus>
	<Pine.LNX.4.50L.0212031855590.22252-100000@duckman.distro.conectiva>
	<6uk7iqyqex.fsf@zork.zork.net>
From: Sean Neakums <sneakums@zork.net>
Date: Wed, 04 Dec 2002 13:33:48 +0000
In-Reply-To: <6uk7iqyqex.fsf@zork.zork.net> (Sean Neakums's message of "Wed,
 04 Dec 2002 11:28:06 +0000")
Message-ID: <6uhedtzz5v.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, The One True Dave Barry <dave@zork.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

commence  Sean Neakums quotation:

> commence  Rik van Riel quotation:
>
>> On Tue, 3 Dec 2002, Martin J. Bligh wrote:
>>
>>> Assuming the extra time is eaten in Sys, not User,
>>
>> It's not. It's idle time.  Looks like something very strange
>> is going on, vmstat and top output would be nice to have...
>
> Just did a build on 2.4.20-rmap15a.  The wall clock time is lower
> than the previous build, but please don't draw any conclusions from
> that until I have a 2.4.20 build redone.
>
> real    108m38.567s
> user    62m46.480s
> sys     29m10.220s

Here is the 2.4.20 time output, and the log, below:

real    100m22.889s
user    61m45.470s
sys     26m28.930s

The differences between the system and wall-clock time are pretty much
the same as seen the previous pair of builds.  (I left the machine
alone for these builds; there was some interactive load during the
previous pair.)


Wed Dec  4 11:43:09 GMT 2002

top - 11:43:10 up 2 min,  4 users,  load average: 0.02, 0.02, 0.00
Tasks:  52 total,   1 running,  51 sleeping,   0 stopped,   0 zombie
Cpu(s):   1.8% user,   3.2% system,   0.0% nice,  94.9% idle
Mem:    255116k total,    70344k used,   184772k free,     4432k buffers
Swap:   265064k total,        0k used,   265064k free,    32172k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
  302 sneakums  19   0   924  924  740 R  1.0  0.4   0:00.04 top
    1 root       9   0   472  472  416 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.00 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
  120 root       9   0   664  664  532 S  0.0  0.3   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.01 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root      11   0  1752 1752 1084 S  0.0  0.7   0:00.04 nmbd
  210 root       9   0  1936 1936 1204 S  0.0  0.8   0:00.00 smbd
  216 root       9   0  1192 1192  972 S  0.0  0.5   0:00.00 sshd
  219 daemon     9   0   552  552  476 S  0.0  0.2   0:00.00 atd
  222 root       9   0   652  652  540 S  0.0  0.3   0:00.01 cron
  226 root       9   0  1412 1412 1324 S  0.0  0.6   0:00.01 apache
  229 sneakums   9   0  1400 1400 1072 S  0.0  0.5   0:00.04 bash
  230 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  231 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  232 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  233 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  234 root       9   0   444  444  392 S  0.0  0.2   0:00.01 getty
  235 www-data   9   0  1428 1428 1348 S  0.0  0.6   0:00.00 apache
  236 www-data   9   0  1428 1428 1348 S  0.0  0.6   0:00.00 apache
  237 www-data   9   0  1428 1428 1348 S  0.0  0.6   0:00.00 apache
  238 www-data   9   0  1428 1428 1348 S  0.0  0.6   0:00.00 apache
  239 www-data   9   0  1428 1428 1348 S  0.0  0.6   0:00.00 apache
  244 sneakums   9   0   996  996  828 S  0.0  0.4   0:00.03 startx
  245 sneakums   9   0   632  632  528 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   756  756  592 S  0.0  0.3   0:00.00 ssh-agent
  259 sneakums   9   0   596  596  524 S  0.0  0.2   0:00.00 xinit
  260 root      17 -10 74136 7832 1688 S  0.0  3.1   0:01.53 XFree86
  263 sneakums   9   0  1040 1040  876 S  0.0  0.4   0:00.02 ion
  264 sneakums   8   0  1596 1596 1288 S  0.0  0.6   0:00.12 xscreensaver
  267 sneakums  14   0  5552 5544 1752 S  0.0  2.2   0:00.15 xterm
  268 sneakums   9   0  1384 1384 1076 S  0.0  0.5   0:00.02 bash
  275 sneakums   9   0   832  828  736 S  0.0  0.3   0:00.02 screen
  276 sneakums  16   0  1452 1452  944 S  0.0  0.6   0:00.09 screen
  277 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.02 bash
  280 root      11   0  1196 1196  972 S  0.0  0.5   0:00.03 bash
  283 sneakums  16   0  1424 1424 1076 S  0.0  0.6   0:00.03 bash
  288 sneakums   7   0  1272 1272 1024 S  0.0  0.5   0:00.02 bash
  291 sneakums  11   0  1404 1404 1068 S  0.0  0.6   0:00.01 bash
  294 sneakums  10   0   484  484  408 S  0.0  0.2   0:00.00 tail

cache hit                              0
cache miss                             0
files in cache                     39730
cache size                         257.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 0  0  0      0 184864   4432  32188    0    0   195    24  169   118  2  3 95
 0  0  0      0 184856   4432  32188    0    0     0     0  141   315  2  0 98
 0  0  0      0 184856   4432  32188    0    0     0     0  144   152  0  0 100
 0  2  0      0 184540   4476  32308    0    0    68    47  145   160  1  0 99
 2  1  0      0 172668   4980  41500    0    0  1096     0  198  2112 52 26 22
 1  1  1      0 168836   5176  44252    0    0  1450  4007  304   542 23 11 66
 2  0  0      0 168268   5308  44776    0    0   326     2  193   474 33 27 40
 1  0  0      0 167828   5344  45096    0    0   176     0  162   736 40 48 11
 0  1  0      0 167408   5420  45276    0    0   102   160  158   545 48 40 12
 2  0  0      0 167124   5444  45336    0    0    40     0  137   420 58 37  4

Wed Dec  4 11:53:29 GMT 2002

top - 11:53:30 up 13 min,  4 users,  load average: 1.38, 1.28, 0.71
Tasks:  60 total,   3 running,  57 sleeping,   0 stopped,   0 zombie
Cpu(s):  49.9% user,  21.8% system,   0.0% nice,  28.3% idle
Mem:    255116k total,   235436k used,    19680k free,    20416k buffers
Swap:   265064k total,      280k used,   264784k free,   150784k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
17120 sneakums   9   0  3808 3808  544 S  3.8  1.5   0:00.54 make
17233 sneakums  11   0   928  928  736 R  1.9  0.4   0:00.05 top
17276 sneakums  14   0   644  632  372 R  1.9  0.2   0:00.02 cpp0
17275 sneakums  13   0   404  404  320 S  1.0  0.2   0:00.01 cc
    1 root       8   0   472  472  416 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.00 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:00.14 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.21 kjournald
  120 root       9   0   664  664  532 S  0.0  0.3   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.01 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1764 1764 1096 S  0.0  0.7   0:00.67 nmbd
  210 root       9   0  1936 1936 1204 S  0.0  0.8   0:00.00 smbd
  216 root       9   0  1120 1112  900 S  0.0  0.4   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.01 cron
  226 root       9   0  1404 1360 1272 R  0.0  0.5   0:00.01 apache
  229 sneakums   9   0  1400 1400 1072 S  0.0  0.5   0:00.04 bash
  230 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  231 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  232 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  233 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  234 root       9   0   444  444  392 S  0.0  0.2   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   996  996  828 S  0.0  0.4   0:00.03 startx
  245 sneakums   9   0   632  632  528 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   596  596  524 S  0.0  0.2   0:00.00 xinit
  260 root       5 -10 74136 7832 1688 S  0.0  3.1   0:01.72 XFree86
  263 sneakums   9   0  1040 1040  876 S  0.0  0.4   0:00.02 ion
  264 sneakums   8   0  1596 1596 1288 S  0.0  0.6   0:00.12 xscreensaver
  267 sneakums   9   0  5552 5544 1748 S  0.0  2.2   0:00.23 xterm
  268 sneakums   9   0  1384 1384 1076 S  0.0  0.5   0:00.02 bash
  275 sneakums   9   0   832  828  736 S  0.0  0.3   0:00.02 screen
  276 sneakums   9   0  1460 1420  904 S  0.0  0.6   0:02.76 screen
  277 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.02 bash
  280 root       9   0  1196 1196  972 S  0.0  0.5   0:00.03 bash
  283 sneakums   9   0  1424 1424 1076 S  0.0  0.6   0:00.04 bash
  288 sneakums   9   0  1272 1272 1024 S  0.0  0.5   0:00.02 bash
  291 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.01 bash
  294 sneakums   9   0   484  484  408 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   744  744  516 S  0.0  0.3   0:00.11 make
 7582 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.00 sh
 7586 sneakums   9   0   744  744  532 S  0.0  0.3   0:00.09 make
 8658 sneakums   9   0  1692 1692  544 S  0.0  0.7   0:00.65 make
17274 sneakums  12   0   400  400  320 S  0.0  0.2   0:00.00 cc

cache hit                           4557
cache miss                             0
called for link                      204
multiple source files                  1
compile failed                        14
preprocessor error                     1
not a C/C++ file                     760
autoconf compile/link                141
unsupported compiler option         2634
no input file                        339
files in cache                     39730
cache size                         257.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0    280  19672  20416 150800    0    0   119   333  160   319 50 22 28
 2  0  0    280  19356  20444 151128    0    0    40     0  136   522 66 26  8
 1  0  0    280  19824  20504 151356    0    0    42   680  174   313 67 22 10
 0  1  0    280  19608  20532 151752    0    0    52     0  138   306 66 28  6
 2  0  0    280  18820  20604 152044    0    0    94   684  186   291 62 24 14
 0  1  0    280  17820  20644 152504    0    0    96     0  147   291 59 26 14
 1  0  0    280  18272  20652 152680    0    0    26     0  131   285 71 27  2
 2  0  0    280  17360  20688 152852    0    0    44   754  174   158 65 25 10
 2  0  0    280  16976  20732 153068    0    0    40     0  140   242 61 32  7
 1  0  0    280  18224  20780 153168    0    0    20   580  159   342 68 27  5

Wed Dec  4 12:03:48 GMT 2002

top - 12:03:49 up 23 min,  4 users,  load average: 1.35, 1.46, 1.08
Tasks:  63 total,   2 running,  61 sleeping,   0 stopped,   0 zombie
Cpu(s):  54.4% user,  23.6% system,   0.0% nice,  22.1% idle
Mem:    255116k total,   242340k used,    12776k free,    20804k buffers
Swap:   265064k total,     2620k used,   262444k free,   165200k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
32755 sneakums  17   0  1208 1208  668 R  5.7  0.5   0:00.06 as
    4 root       9   0     0    0    0 S  0.9  0.0   0:01.20 kswapd
32754 sneakums  10   0   928  928  736 R  0.9  0.4   0:00.04 top
    1 root       8   0   472  472  416 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.01 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.11 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.03 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.76 kjournald
  120 root       9   0   600  532  468 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.01 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:01.13 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       9   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0  1400 1400 1072 S  0.0  0.5   0:00.04 bash
  230 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  231 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  232 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  233 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  234 root       9   0   444  444  392 S  0.0  0.2   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   996  996  828 S  0.0  0.4   0:00.03 startx
  245 sneakums   9   0   632  632  528 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   596  596  524 S  0.0  0.2   0:00.00 xinit
  260 root       5 -10 74416 8112 1688 S  0.0  3.2   0:01.89 XFree86
  263 sneakums   9   0   652  544  488 S  0.0  0.2   0:00.02 ion
  264 sneakums   8   0  1872 1872 1436 S  0.0  0.7   0:00.12 xscreensaver
  267 sneakums   9   0  4264 3072  460 S  0.0  1.2   0:00.24 xterm
  268 sneakums   9   0  1384 1384 1076 S  0.0  0.5   0:00.02 bash
  275 sneakums   9   0   832  828  736 S  0.0  0.3   0:00.02 screen
  276 sneakums   9   0  1460 1420  904 S  0.0  0.6   0:05.22 screen
  277 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.02 bash
  280 root       9   0  1196 1196  972 S  0.0  0.5   0:00.03 bash
  283 sneakums   9   0  1424 1424 1076 S  0.0  0.6   0:00.04 bash
  288 sneakums   9   0  1272 1272 1024 S  0.0  0.5   0:00.02 bash
  291 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.01 bash
  294 sneakums   9   0   484  484  408 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   744  744  516 S  0.0  0.3   0:00.11 make
25709 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh
25713 sneakums   9   0   740  740  532 S  0.0  0.3   0:00.09 make
25814 sneakums   9   0   916  916  756 S  0.0  0.4   0:00.00 sh
25818 sneakums   9   0   732  732  532 S  0.0  0.3   0:00.05 make
31002 sneakums   9   0   888  888  532 S  0.0  0.3   0:00.09 make
31315 sneakums   9   0  1024 1024  780 S  0.0  0.4   0:00.02 sh
31362 sneakums   9   0   956  956  532 S  0.0  0.4   0:00.05 make
32601 sneakums   9   0   980  980  532 S  0.0  0.4   0:00.11 make
32750 sneakums  12   0   448  448  356 S  0.0  0.2   0:00.01 xgcc

cache hit                           6845
cache miss                             1
called for link                      335
multiple source files                  2
compile failed                        20
preprocessor error                     2
not a C/C++ file                     827
autoconf compile/link                298
unsupported compiler option         2635
no input file                        535
files in cache                     39732
cache size                         257.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 2  0  0   2620  13816  20816 164700    0    2   193   617  172   436 54 24 22
 1  0  0   2620   9932  20820 165236    0    0     0     0  134   108 94  6  0
 1  0  0   2620   9204  20872 165356    0    0     3   533  178    37 99  1  0
 1  0  0   2620   9800  20876 165300    0    0     0     0  144    34 95  5  0
 1  0  0   2620  10208  20896 165208    0    0     0   476  173    34 97  3  0
 1  0  0   2620   9544  20904 165572    0    0     0     0  132    19 97  3  0
 1  0  0   2620   9184  20908 165680    0    0     0     0  145    18 100  0  0
 1  0  0   2620   5292  20920 165688    0    0     0   542  148    29 100  0  0
 1  0  0   2620   7296  20916 165164    0    0     0     0  143    20 100  0  0
 1  0  0   2620  10752  20928 164760    0    0     0   186  162    29 97  3  0

Wed Dec  4 12:14:08 GMT 2002

top - 12:14:09 up 33 min,  4 users,  load average: 1.31, 1.20, 1.10
Tasks:  58 total,   2 running,  55 sleeping,   0 stopped,   1 zombie
Cpu(s):  64.9% user,  19.2% system,   0.0% nice,  15.8% idle
Mem:    255116k total,   247652k used,     7464k free,    16648k buffers
Swap:   265064k total,     3388k used,   261676k free,   181680k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
18542 sneakums  11   0  1044 1044  824 R  9.3  0.4   0:00.10 configure
18500 sneakums  10   0   928  928  736 R  1.9  0.4   0:00.03 top
    4 root       9   0     0    0    0 S  0.9  0.0   0:01.35 kswapd
18463 sneakums   9   0   736  736  532 S  0.9  0.3   0:00.05 make
18541 sneakums   9   0   920  920  764 S  0.9  0.4   0:00.01 sh
18696 sneakums  11   0     0    0    0 Z  0.9  0.0   0:00.01 cat <defunct>
    1 root       8   0   472  472  416 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.01 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.11 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.03 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.85 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.01 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:01.42 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0  1400 1400 1072 S  0.0  0.5   0:00.04 bash
  230 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  231 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  232 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  233 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  234 root       9   0   444  444  392 S  0.0  0.2   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   996  996  828 S  0.0  0.4   0:00.03 startx
  245 sneakums   9   0   632  632  528 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   596  596  524 S  0.0  0.2   0:00.00 xinit
  260 root       5 -10 74420 8116 1688 S  0.0  3.2   0:02.27 XFree86
  263 sneakums   9   0   668  572  516 S  0.0  0.2   0:00.02 ion
  264 sneakums   9   0  1748 1748 1436 S  0.0  0.7   0:00.13 xscreensaver
  267 sneakums   9   0  4328 2392  544 S  0.0  0.9   0:00.30 xterm
  268 sneakums   9   0  1384 1384 1076 S  0.0  0.5   0:00.02 bash
  275 sneakums   9   0   832  828  736 S  0.0  0.3   0:00.02 screen
  276 sneakums   9   0  1460 1420  904 S  0.0  0.6   0:05.55 screen
  277 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.02 bash
  280 root       9   0  1196 1196  972 S  0.0  0.5   0:00.03 bash
  283 sneakums   9   0  1424 1424 1076 S  0.0  0.6   0:00.05 bash
  288 sneakums   9   0  1272 1272 1024 S  0.0  0.5   0:00.02 bash
  291 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.01 bash
  294 sneakums   9   0   484  484  408 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   748  748  516 S  0.0  0.3   0:00.12 make
18459 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh

cache hit                           6926
cache miss                             1
called for link                      339
multiple source files                  3
compile failed                        25
preprocessor error                     2
not a C/C++ file                     831
autoconf compile/link                375
unsupported compiler option         2635
no input file                        543
files in cache                     39732
cache size                         257.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 2  0  0   3388   7048  16656 181736    0    1   147   507  162   336 65 19 16
 2  0  0   3388   7248  16672 181756    0    0    12     0  147   352 61 36  2
 2  0  0   3388   6580  16888 182204    0    0   154   887  221   301 41 22 37
 1  0  0   3388   4992  17076 183012    0    0   146     0  176   414 61 24 14
 0  1  0   3772   8776  17084 183352    0    0   220  1110  227   319 53 20 26
 0  1  0   3772   6324  17228 185284    0    0   396     0  177   477 50 21 28
 2  0  0   3772   4820  17028 186392    0    0   732     0  192  1529 55 29 16
 1  0  0   3772   4388  17148 186376    0    0   124  3954  252   143 33 13 53
 1  0  0   3772   6020  17232 185360    0    0   114     0  172   290 59 27 14
 1  0  0   3772   4920  17416 185512    0    0   438  2162  217  1006 59 27 14

Wed Dec  4 12:24:27 GMT 2002

top - 12:24:28 up 44 min,  4 users,  load average: 1.14, 1.35, 1.25
Tasks:  65 total,   2 running,  63 sleeping,   0 stopped,   0 zombie
Cpu(s):  64.7% user,  20.3% system,   0.0% nice,  15.0% idle
Mem:    255116k total,   250736k used,     4380k free,    20532k buffers
Swap:   265064k total,     5304k used,   259760k free,   173372k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
27902 sneakums  16   0  7160 7160 1748 R 96.9  2.8   0:01.45 cc1
27905 sneakums  11   0   932  932  736 R  1.9  0.4   0:00.04 top
27903 sneakums   9   0  1112 1112  676 S  0.9  0.4   0:00.01 as
    1 root       8   0   472  472  416 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.01 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:02.02 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.14 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.07 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:01.19 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.02 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:01.76 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0  1400 1400 1072 S  0.0  0.5   0:00.04 bash
  230 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  231 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  232 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  233 root       9   0   444  444  392 S  0.0  0.2   0:00.00 getty
  234 root       9   0   444  444  392 S  0.0  0.2   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   996  996  828 S  0.0  0.4   0:00.03 startx
  245 sneakums   9   0   632  632  528 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   596  596  524 S  0.0  0.2   0:00.00 xinit
  260 root       5 -10 74420 8116 1688 S  0.0  3.2   0:03.42 XFree86
  263 sneakums   9   0   668  572  516 S  0.0  0.2   0:00.02 ion
  264 sneakums   9   0  1748 1748 1436 S  0.0  0.7   0:00.13 xscreensaver
  267 sneakums   9   0  4384  860  604 S  0.0  0.3   0:00.37 xterm
  268 sneakums   9   0   308    0    0 S  0.0  0.0   0:00.02 bash
  275 sneakums   9   0   772  752  676 S  0.0  0.3   0:00.02 screen
  276 sneakums   9   0  1460 1420  904 S  0.0  0.6   0:06.82 screen
  277 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.02 bash
  280 root       9   0  1196 1196  972 S  0.0  0.5   0:00.03 bash
  283 sneakums   9   0  1424 1424 1076 S  0.0  0.6   0:00.05 bash
  288 sneakums   9   0  1272 1272 1024 S  0.0  0.5   0:00.02 bash
  291 sneakums   9   0  1404 1404 1068 S  0.0  0.6   0:00.01 bash
  294 sneakums   9   0   484  484  408 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   760  760  516 S  0.0  0.3   0:00.15 make
16778 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.00 sh
16782 sneakums   9   0   736  736  532 S  0.0  0.3   0:00.09 make
16883 sneakums   9   0   916  916  756 S  0.0  0.4   0:00.01 sh
16887 sneakums   9   0   748  748  532 S  0.0  0.3   0:00.10 make
21466 sneakums   9   0  1320 1320  544 S  0.0  0.5   0:00.27 make
25124 sneakums   9   0  1384 1384  544 S  0.0  0.5   0:00.17 make
27477 sneakums   9   0  1604 1604  544 S  0.0  0.6   0:00.42 make
27892 sneakums   9   0  1372 1372  544 S  0.0  0.5   0:00.15 make
27898 sneakums   9   0   400  400  328 S  0.0  0.2   0:00.02 gcc
27901 sneakums   9   0   412  412  328 S  0.0  0.2   0:00.00 gcc

cache hit                           8718
cache miss                            18
called for link                      427
multiple source files                  5
compile failed                        44
preprocessor error                     5
not a C/C++ file                     870
autoconf compile/link                709
unsupported compiler option         2638
no input file                        571
files in cache                     39766
cache size                         258.2 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0   5304   4424  20540 173288    0    2   187   545  166   373 65 20 15
 2  0  0   5304  11964  20556 171828    0    0     2     0  125   166 97  3  0
 1  0  0   5304  11068  20588 172620    0    0   164     0  158   155 74 21  5
 1  0  0   5304   9772  20632 172156    0    0    48   463  143    88 87 11  2
 1  0  0   5304  10064  20668 173152    0    0   142     0  143   143 76 21  3
 1  0  0   5304   9584  20696 172808    0    0    40   755  161    65 94  5  1
 1  0  0   5304   8588  20720 173600    0    0   296     0  161   151 73 20  7
 0  1  2   5304   8832  20776 174708    0    0   258   466  160   141 70 24  6
 1  0  0   5304   7576  20840 175764    0    0   592   282  190   194 70 22  8
 1  0  0   5304   5256  20880 176192    0    0   440     0  174   169 70 26  4

Wed Dec  4 12:34:47 GMT 2002

top - 12:34:48 up 54 min,  4 users,  load average: 1.73, 1.57, 1.37
Tasks:  58 total,   3 running,  55 sleeping,   0 stopped,   0 zombie
Cpu(s):  62.9% user,  21.6% system,   0.0% nice,  15.5% idle
Mem:    255116k total,   248956k used,     6160k free,    34684k buffers
Swap:   265064k total,     7524k used,   257540k free,   161680k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
17250 sneakums  11   0  1052 1052 1048 R  6.7  0.4   0:00.43 configure
  276 sneakums   9   0  1356 1076  756 S  1.0  0.4   0:08.90 screen
17802 sneakums  10   0   928  928  736 R  1.0  0.4   0:00.04 top
    1 root       8   0   444  408  388 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.02 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:02.91 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.27 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.13 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:01.64 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.02 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:02.17 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0   960  824  632 S  0.0  0.3   0:00.04 bash
  230 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  231 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  232 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  233 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  234 root       9   0   420  368  368 S  0.0  0.1   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   996  996  828 S  0.0  0.4   0:00.03 startx
  245 sneakums   9   0   632  632  528 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   596  596  524 S  0.0  0.2   0:00.00 xinit
  260 root       5 -10 74420 8116 1688 S  0.0  3.2   0:03.65 XFree86
  263 sneakums   9   0   668  572  516 S  0.0  0.2   0:00.02 ion
  264 sneakums   9   0  1404 1360 1092 S  0.0  0.5   0:00.14 xscreensaver
  267 sneakums   9   0  4388  864  608 S  0.0  0.3   0:00.37 xterm
  268 sneakums   9   0   308    0    0 S  0.0  0.0   0:00.02 bash
  275 sneakums   9   0   764  604  584 S  0.0  0.2   0:00.02 screen
  277 sneakums   9   0  1108  772  772 S  0.0  0.3   0:00.02 bash
  280 root       9   0  1096  872  872 S  0.0  0.3   0:00.03 bash
  283 sneakums   9   0  1124  896  776 S  0.0  0.4   0:00.06 bash
  288 sneakums   9   0  1132  884  884 S  0.0  0.3   0:00.02 bash
  291 sneakums   9   0   928  592  592 S  0.0  0.2   0:00.01 bash
  294 sneakums   9   0   460  424  384 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   480  440  224 S  0.0  0.2   0:00.22 make
17169 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh
17173 sneakums   9   0   736  736  532 S  0.0  0.3   0:00.05 make
17249 sneakums   9   0   920  920  764 S  0.0  0.4   0:00.00 sh
18026 sneakums  11   0  1052 1052 1048 R  0.0  0.4   0:00.00 configure

cache hit                          11184
cache miss                            24
called for link                      498
multiple source files                  7
compile failed                        67
preprocessor error                     6
not a C/C++ file                     942
autoconf compile/link               1150
unsupported compiler option         2679
no input file                        605
files in cache                     39778
cache size                         258.3 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0   7524   6072  34692 161728    0    2   227   588  173   431 63 22 15
 0  1  0   7524   5424  34760 162084   32    0    87   387  181   645 55 41  4
 1  0  0   7820   6428  34780 161900    0    0   232     0  158   239 66 29  4
 2  0  0   7820   5228  34820 163332    0    0    96     0  144   379 60 35  5
 1  0  0   7820   4352  34852 164420    0    0   990  2016  206  1951 59 27 13
 2  0  0   7820   6036  34228 163224    0    0    10     0  130   953 24 25 51
 0  2  2   7820  12664  33732 156740    0    0     4  5240  256   280 33 22 44
 1  0  0   7820  12664  33700 156624    0    0     6     2  133   499 52 43  4
 1  0  0   7820  12780  33724 156660    0    0     4   276  147   371 26 22 51
 2  0  0   7820  12160  33756 156844    0    0    16     0  138   566 54 43  3

Wed Dec  4 12:45:07 GMT 2002

top - 12:45:08 up  1:04,  4 users,  load average: 1.47, 1.49, 1.44
Tasks:  64 total,   2 running,  62 sleeping,   0 stopped,   0 zombie
Cpu(s):  63.0% user,  22.5% system,   0.0% nice,  14.5% idle
Mem:    255116k total,   247436k used,     7680k free,    20348k buffers
Swap:   265064k total,     8388k used,   256676k free,   180176k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
15242 sneakums  13   0   680  680  532 S  1.9  0.3   0:00.03 make
  276 sneakums   9   0  1356 1088  768 S  0.9  0.4   0:10.34 screen
15239 sneakums  10   0   932  932  736 R  0.9  0.4   0:00.03 top
15374 sneakums  17   0   928  928  756 S  0.9  0.4   0:00.01 sh
15375 sneakums  17   0  1020 1020  788 R  0.9  0.4   0:00.01 ld
    1 root       8   0   444  408  388 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.02 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:03.56 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.30 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.14 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:02.01 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.02 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:02.48 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0   928  600  600 S  0.0  0.2   0:00.04 bash
  230 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  231 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  232 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  233 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  234 root       9   0   420  368  368 S  0.0  0.1   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   676  512  508 S  0.0  0.2   0:00.03 startx
  245 sneakums   9   0   544  440  440 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   388  316  316 S  0.0  0.1   0:00.00 xinit
  260 root       5 -10 73856 7224 1128 S  0.0  2.8   0:03.96 XFree86
  263 sneakums   8   0   716  640  584 S  0.0  0.3   0:00.02 ion
  264 sneakums   8   0  1408 1364 1096 S  0.0  0.5   0:00.14 xscreensaver
  267 sneakums   9   0  4388  864  608 S  0.0  0.3   0:00.41 xterm
  268 sneakums   9   0   308    0    0 S  0.0  0.0   0:00.02 bash
  275 sneakums   9   0   764  604  584 S  0.0  0.2   0:00.02 screen
  277 sneakums   9   0  1108  772  772 S  0.0  0.3   0:00.02 bash
  280 root       9   0  1096  872  872 S  0.0  0.3   0:00.03 bash
  283 sneakums   9   0  1124  896  776 S  0.0  0.4   0:00.06 bash
  288 sneakums   9   0  1132  884  884 S  0.0  0.3   0:00.02 bash
  291 sneakums   9   0   928  592  592 S  0.0  0.2   0:00.01 bash
  294 sneakums   9   0   460  424  384 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   492  456  228 S  0.0  0.2   0:00.23 make
13620 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh
13624 sneakums   9   0   740  740  532 S  0.0  0.3   0:00.03 make
13733 sneakums   9   0   660  660  532 S  0.0  0.3   0:00.00 make
13734 sneakums   9   0   932  932  844 S  0.0  0.4   0:00.01 sh
13880 sneakums   9   0   952  952  856 S  0.0  0.4   0:00.00 sh
13881 sneakums   9   0   668  668  532 S  0.0  0.3   0:00.01 make
13882 sneakums   9   0   912  912  824 S  0.0  0.4   0:00.00 sh
15241 sneakums   9   0   956  956  856 S  0.0  0.4   0:00.00 sh

cache hit                          12418
cache miss                            30
called for link                     1008
multiple source files                 12
compile failed                        95
preprocessor error                     6
not a C/C++ file                    1034
autoconf compile/link               1642
unsupported compiler option         2679
no input file                        619
files in cache                     39790
cache size                         258.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0   8388   8132  20352 180228    0    2   215   600  171   431 63 23 15
 1  0  0   8388   9744  20420 178544   16    0   122  3549  250   376 34 26 40
 1  0  0   8388   6392  20488 178512    0    0   178     0  155   347 57 40  3
 1  0  0   8388   9244  20572 178888    0    0   272  4020  266   269 46 25 28
 1  0  0   8388   7848  20664 178600    0    0   378     0  167   309 54 36  9
 1  0  2   8388   4412  20544 179384    0    0   158   310  159   336 61 35  4
 1  0  0   8388  11156  20176 173168    0    0   112  5464  287   450 44 35 20
 2  0  0   8388  10056  20208 174100    0    0   174     0  155   449 60 36  3
 1  0  0   8388   9376  20252 175068    0    0   176  3838  271   403 50 35 14
 2  0  0   8388   8024  20284 176008    0    0   170     0  156   442 58 38  4

Wed Dec  4 12:55:26 GMT 2002

top - 12:55:27 up  1:15,  4 users,  load average: 2.41, 1.84, 1.57
Tasks:  58 total,   1 running,  57 sleeping,   0 stopped,   0 zombie
Cpu(s):  62.3% user,  24.1% system,   0.0% nice,  13.6% idle
Mem:    255116k total,   250536k used,     4580k free,    19596k buffers
Swap:   265064k total,     9540k used,   255524k free,   185688k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
10370 sneakums  13   0  1056 1056  824 S  8.5  0.4   0:00.09 configure
10272 sneakums   9   0   740  740  532 S  1.9  0.3   0:00.05 make
10328 sneakums  11   0   924  924  736 R  1.9  0.4   0:00.03 top
10369 sneakums   9   0   928  928  764 S  0.9  0.4   0:00.01 sh
    1 root       8   0   444  408  388 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.02 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:04.04 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.33 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.17 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:02.47 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.03 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:02.98 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0   928  600  600 S  0.0  0.2   0:00.04 bash
  230 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  231 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  232 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  233 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  234 root       9   0   420  368  368 S  0.0  0.1   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   676  512  508 S  0.0  0.2   0:00.03 startx
  245 sneakums   9   0   544  440  440 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   388  316  316 S  0.0  0.1   0:00.00 xinit
  260 root       5 -10 73856 6072 1128 S  0.0  2.4   0:03.96 XFree86
  263 sneakums   8   0   716  640  584 S  0.0  0.3   0:00.02 ion
  264 sneakums   8   0  1412 1368 1100 S  0.0  0.5   0:00.14 xscreensaver
  267 sneakums   9   0  4388  864  608 S  0.0  0.3   0:00.41 xterm
  268 sneakums   9   0   308    0    0 S  0.0  0.0   0:00.02 bash
  275 sneakums   9   0   764  604  584 S  0.0  0.2   0:00.02 screen
  276 sneakums   9   0  1356 1108  788 S  0.0  0.4   0:11.81 screen
  277 sneakums   9   0  1108  772  772 S  0.0  0.3   0:00.02 bash
  280 root       9   0  1096  872  872 S  0.0  0.3   0:00.03 bash
  283 sneakums   9   0  1124  896  776 S  0.0  0.4   0:00.07 bash
  288 sneakums   9   0  1132  884  884 S  0.0  0.3   0:00.02 bash
  291 sneakums   9   0   928  592  592 S  0.0  0.2   0:00.01 bash
  294 sneakums   9   0   460  424  384 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   500  464  228 S  0.0  0.2   0:00.26 make
10268 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh
10462 sneakums  13   0   512  512  432 S  0.0  0.2   0:00.00 sleep

cache hit                          14783
cache miss                            33
called for link                     1110
multiple source files                 18
compile failed                       123
preprocessor error                     7
not a C/C++ file                    1104
autoconf compile/link               1968
unsupported compiler option         2681
no input file                        645
files in cache                     39796
cache size                         258.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 0  0  0   9540   4632  19608 185732    0    2   201   594  169   439 62 24 14
 2  0  0   9540   6136  19512 184308   10    0    12     0  135   451 30 33 37
 2  0  0   9540  12564  19156 178084    0    0     8  3381  198   603 50 43  6
 2  0  0   9540  12268  19164 178140    0    0    20     0  133   366 60 38  2
 1  0  0   9540  11516  19204 178980    0    0   410   280  167   378 60 31  9
 2  0  0   9540  11052  19204 179216    0    0     0     0  126   630 69 31  0
 2  0  0   9540  10488  19228 179496    0    0    36     0  138   555 60 37  3
 1  0  0   9540   9424  19300 179940    0    0   110   546  175   204 70 22  7
 1  0  0   9540   7868  19400 180752    0    0   140     0  158   206 66 28  5
 0  1  0   9540   7656  19496 181496    0    0    96   896  218   154 41 21 38

Wed Dec  4 13:05:46 GMT 2002

top - 13:05:47 up  1:25,  4 users,  load average: 1.50, 1.79, 1.76
Tasks:  62 total,   2 running,  60 sleeping,   0 stopped,   0 zombie
Cpu(s):  61.8% user,  25.4% system,   0.0% nice,  12.8% idle
Mem:    255116k total,   248964k used,     6152k free,    21436k buffers
Swap:   265064k total,    10180k used,   254884k free,   180416k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
23530 sneakums  11   0  1112 1112 1088 S 10.5  0.4   0:01.41 configure
26403 sneakums  11   0   932  932  736 R  1.9  0.4   0:00.05 top
  276 sneakums   9   0  1356 1116  796 S  1.0  0.4   0:13.02 screen
    1 root       8   0   444  408  388 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.02 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:04.38 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.33 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.20 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:02.70 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.03 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:03.34 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0   928  600  600 S  0.0  0.2   0:00.04 bash
  230 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  231 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  232 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  233 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  234 root       9   0   420  368  368 S  0.0  0.1   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   676  512  508 S  0.0  0.2   0:00.03 startx
  245 sneakums   9   0   544  440  440 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   388  316  316 S  0.0  0.1   0:00.00 xinit
  260 root       5 -10 73856 5432 1128 S  0.0  2.1   0:03.96 XFree86
  263 sneakums   8   0   716  640  584 S  0.0  0.3   0:00.02 ion
  264 sneakums   9   0  1412 1368 1100 S  0.0  0.5   0:00.15 xscreensaver
  267 sneakums   9   0  4388  864  608 S  0.0  0.3   0:00.42 xterm
  268 sneakums   9   0   308    0    0 S  0.0  0.0   0:00.02 bash
  275 sneakums   9   0   764  604  584 S  0.0  0.2   0:00.02 screen
  277 sneakums   9   0  1108  772  772 S  0.0  0.3   0:00.02 bash
  280 root       9   0  1096  872  872 S  0.0  0.3   0:00.03 bash
  283 sneakums   9   0  1124  896  776 S  0.0  0.4   0:00.07 bash
  288 sneakums   9   0  1132  884  884 S  0.0  0.3   0:00.02 bash
  291 sneakums   9   0   928  592  592 S  0.0  0.2   0:00.01 bash
  294 sneakums   9   0   460  424  384 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   524  492  232 S  0.0  0.2   0:00.44 make
22030 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh
22034 sneakums   9   0   848  848  532 S  0.0  0.3   0:00.65 make
23357 sneakums   9   0   916  916  756 S  0.0  0.4   0:00.00 sh
23361 sneakums   9   0   728  728  532 S  0.0  0.3   0:00.07 make
23435 sneakums   9   0   924  924  756 S  0.0  0.4   0:00.00 sh
23439 sneakums   9   0   732  732  532 S  0.0  0.3   0:00.06 make
23529 sneakums   9   0   932  932  764 S  0.0  0.4   0:00.01 sh
26586 sneakums  10   0  1112 1112 1088 R  0.0  0.4   0:00.00 configure

cache hit                          16737
cache miss                            34
called for link                     1251
multiple source files                 25
compile failed                       231
ccache internal error                  1
preprocessor error                    34
not a C/C++ file                    1136
autoconf compile/link               3071
unsupported compiler option         2681
no input file                        702
files in cache                     39798
cache size                         258.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 2  0  0  10180   5732  21448 180472    0    2   188   572  167   439 62 25 13
 2  0  0  10180   5420  21384 180448   20    0    30     0  130   401 58 41  1
 1  0  0  10180   4356  21360 180440    0    0    18   323  169   376 57 42  0
 1  0  0  10180   4600  21360 180452    0    0    14     0  135   280 67 32  0
 0  0  0  10180   6072  21388 180400    0    0     6     0  129   216 60 25 15
 1  0  0  10180   6204  21412 180392    0    0     0   254  148    70 10  5 85
 1  0  0  10180   4420  21392 180404    0    0    22     0  131   402 54 46  0
 2  0  0  10180   6132  21436 180420    0    0    12   240  154   350 62 36  2
 2  0  0  10180   5752  21460 180652    0    0     0     0  135   646 60 40  0
 2  0  0  10180   5808  21476 180620    0    0   208     0  154   268 67 29  4

Wed Dec  4 13:16:05 GMT 2002

top - 13:16:06 up  1:35,  4 users,  load average: 1.21, 1.40, 1.57
Tasks:  60 total,   2 running,  58 sleeping,   0 stopped,   0 zombie
Cpu(s):  61.2% user,  26.2% system,   0.0% nice,  12.6% idle
Mem:    255116k total,   249112k used,     6004k free,    22152k buffers
Swap:   265064k total,    10948k used,   254116k free,   172464k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
 6924 sneakums  12   0  1088 1088  948 S  7.5  0.4   0:01.00 configure
 8559 sneakums  11   0   928  928  736 R  1.9  0.4   0:00.05 top
   81 root       9   0     0    0    0 S  0.9  0.0   0:02.89 kjournald
    1 root       8   0   444  408  388 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.02 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:04.91 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.04 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.33 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.24 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.03 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root       9   0  1676 1264 1008 S  0.0  0.5   0:03.77 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0   928  600  600 S  0.0  0.2   0:00.04 bash
  230 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  231 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  232 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  233 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  234 root       9   0   420  368  368 S  0.0  0.1   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   676  512  508 S  0.0  0.2   0:00.03 startx
  245 sneakums   9   0   544  440  440 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   676  584  512 S  0.0  0.2   0:00.00 ssh-agent
  259 sneakums   9   0   388  316  316 S  0.0  0.1   0:00.00 xinit
  260 root       5 -10 73856 4664 1128 S  0.0  1.8   0:03.96 XFree86
  263 sneakums   8   0   716  640  584 S  0.0  0.3   0:00.02 ion
  264 sneakums   9   0  1412 1368 1100 S  0.0  0.5   0:00.15 xscreensaver
  267 sneakums   9   0  4388  864  608 S  0.0  0.3   0:00.43 xterm
  268 sneakums   9   0   308    0    0 S  0.0  0.0   0:00.02 bash
  275 sneakums   9   0   764  604  584 S  0.0  0.2   0:00.02 screen
  276 sneakums   9   0  1356 1128  808 S  0.0  0.4   0:14.49 screen
  277 sneakums   9   0  1108  772  772 S  0.0  0.3   0:00.02 bash
  280 root       9   0  1096  872  872 S  0.0  0.3   0:00.03 bash
  283 sneakums   9   0  1124  896  776 S  0.0  0.4   0:00.07 bash
  288 sneakums   9   0  1132  884  884 S  0.0  0.3   0:00.02 bash
  291 sneakums   9   0   928  592  592 S  0.0  0.2   0:00.01 bash
  294 sneakums   9   0   460  424  384 S  0.0  0.2   0:00.00 tail
  305 sneakums   9   0   544  512  232 S  0.0  0.2   0:00.58 make
32310 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh
32317 sneakums   9   0   768  768  532 S  0.0  0.3   0:00.17 make
 6843 sneakums   9   0   928  928  756 S  0.0  0.4   0:00.01 sh
 6847 sneakums   9   0   732  732  532 S  0.0  0.3   0:00.03 make
 6923 sneakums   9   0   932  932  764 S  0.0  0.4   0:00.00 sh
 8689 sneakums  11   0  1088 1088  948 R  0.0  0.4   0:00.00 configure

cache hit                          18670
cache miss                            41
called for link                     1422
multiple source files                 26
compile failed                       305
ccache internal error                  1
preprocessor error                    53
not a C/C++ file                    1182
autoconf compile/link               4209
unsupported compiler option         2743
no input file                        725
files in cache                     39812
cache size                         258.6 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 2  0  0  10948   5540  22160 172524    0    2   185   562  167   443 61 26 13
 1  0  0  10948   6108  22160 172528   14    0    14     0  123   404 64 36  0
 2  0  0  10948   4516  22160 172412    0    0     0     0  127   471 55 45  0
 2  0  0  10948   5516  22192 172424    0    0     0   241  142   308 67 32  0
 2  0  0  10948   4520  22196 172316    0    0     2     0  131   324 58 41  0
 1  0  0  10948   6276  22212 172316    0    0     2   164  132   405 56 43  1
 1  0  0  10948   6076  22212 172396    0    0     0     0  127   398 49 51  0
 2  0  0  10948   5520  22216 172608    0    0     0     0  124   600 62 38  0
 1  0  0  10948   5240  22276 172828    0    0    60   434  203   334 68 28  3
 1  0  0  10948   4616  22108 171956    0    0    60     0  146   234 70 28  1

Wed Dec  4 13:26:24 GMT 2002

top - 13:26:26 up  1:46,  5 users,  load average: 0.09, 0.80, 1.24
Tasks:  55 total,   1 running,  54 sleeping,   0 stopped,   0 zombie
Cpu(s):  58.5% user,  25.5% system,   0.0% nice,  16.0% idle
Mem:    255116k total,   250712k used,     4404k free,    13692k buffers
Swap:   265064k total,    12832k used,   252232k free,   190796k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
 8156 sneakums  17   0  5588 5588 1768 S  1.0  2.2   0:00.30 xterm
 8171 sneakums  14   0   924  924  736 R  1.0  0.4   0:00.04 top
    1 root       8   0   444  408  388 S  0.0  0.2   0:03.85 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.02 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:06.36 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.08 bdflush
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.42 kupdated
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   43 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   79 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.25 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:03.60 kjournald
  120 root       8   0   636  612  548 S  0.0  0.2   0:00.00 dhclient
  189 root       9   0   584  584  480 S  0.0  0.2   0:00.03 syslogd
  192 root       9   0  1252 1252  420 S  0.0  0.5   0:00.18 klogd
  200 root       9   0   488  488  424 S  0.0  0.2   0:00.00 inetd
  204 root       9   0   556  556  468 S  0.0  0.2   0:00.02 lpd
  208 root      11   0  1676 1264 1008 S  0.0  0.5   0:04.12 nmbd
  210 root       9   0  1720 1236  988 S  0.0  0.5   0:00.00 smbd
  216 root       9   0   940  848  720 S  0.0  0.3   0:00.00 sshd
  219 daemon     9   0   552  532  476 S  0.0  0.2   0:00.00 atd
  222 root       8   0   652  652  540 S  0.0  0.3   0:00.02 cron
  226 root       9   0  1404 1360 1272 S  0.0  0.5   0:00.01 apache
  229 sneakums   9   0   928  600  600 S  0.0  0.2   0:00.04 bash
  230 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  231 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  232 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  233 root       9   0   420  368  368 S  0.0  0.1   0:00.00 getty
  234 root       9   0   420  368  368 S  0.0  0.1   0:00.01 getty
  235 www-data   9   0  1328 1212 1132 S  0.0  0.5   0:00.00 apache
  236 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  237 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  238 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  239 www-data   9   0  1336 1220 1140 S  0.0  0.5   0:00.00 apache
  244 sneakums   9   0   676  512  508 S  0.0  0.2   0:00.03 startx
  245 sneakums   9   0   544  440  440 S  0.0  0.2   0:00.01 vlock
  246 sneakums   9   0   788  728  632 S  0.0  0.3   0:00.01 ssh-agent
  259 sneakums   9   0   388  316  316 S  0.0  0.1   0:00.00 xinit
  260 root      16 -10 73820 2712 1040 S  0.0  1.1   0:05.12 XFree86
  263 sneakums   9   0   796  724  668 S  0.0  0.3   0:00.03 ion
  264 sneakums   9   0  1416 1372 1104 S  0.0  0.5   0:00.19 xscreensaver
  267 sneakums   9   0  4628 1124  864 S  0.0  0.4   0:00.57 xterm
  268 sneakums   9   0   308    0    0 S  0.0  0.0   0:00.02 bash
  275 sneakums   9   0   764  604  584 S  0.0  0.2   0:00.02 screen
  276 sneakums   9   0  1356 1136  816 S  0.0  0.4   0:16.87 screen
  277 sneakums   9   0  1108  772  772 S  0.0  0.3   0:00.02 bash
  280 root       9   0  1096  872  872 S  0.0  0.3   0:00.03 bash
  283 sneakums  10   0  1124  896  776 S  0.0  0.4   0:00.07 bash
  288 sneakums   8   0  1168 1044 1008 S  0.0  0.4   0:00.02 bash
  291 sneakums   9   0   928  592  592 S  0.0  0.2   0:00.01 bash
  294 sneakums   9   0   460  424  384 S  0.0  0.2   0:00.00 tail
 8157 sneakums  10   0  1384 1384 1072 S  0.0  0.5   0:00.02 bash
 8169 sneakums  14   0  1700 1700 1216 S  0.0  0.7   0:00.13 ssh

cache hit                          20143
cache miss                            43
called for link                     1556
multiple source files                 28
compile failed                       344
ccache internal error                  1
preprocessor error                    68
not a C/C++ file                    1220
autoconf compile/link               4502
unsupported compiler option         2751
no input file                       1146
files in cache                     39816
cache size                         258.7 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 0  0  0  12832   4472  13692 190840    0    2   269   640  173   453 59 25 16
 0  0  0  12832   4424  13720 190840   10    0    10    53  131    24  0  0 100
 0  0  0  12832   4424  13720 190840    0    0     0     0  265   324  0  0 100
 0  0  0  12832   4416  13728 190840    0    0     0    48  359   511  0  0 99
 0  0  0  12832   4416  13728 190840    0    0     0     0  174   147  1  0 99
 0  0  0  12832   4416  13728 190840    0    0     0     0  127    52  0  0 100
 0  0  0  12832   4408  13736 190840    0    0     0     8  139    78  0  0 99
 0  0  0  12832   4408  13736 190840    0    0     0     0  134    53  0  0 100
 0  0  0  12832   4392  13744 190844    0    0     0    18  144    78  0  0 100
 0  0  0  12832   4392  13744 190844    0    0     0     0  136   119  0  0 100



--
 /                          |
[|] Sean Neakums            |  Questions are a burden to others;
[|] <sneakums@zork.net>     |      answers a prison for oneself.
 \                          |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
