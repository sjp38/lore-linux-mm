Subject: Re: [PATCH] 2.4.20-rmap15a
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com>
	<6usmxfys45.fsf@zork.zork.net> <20021203195854.GA6709@zork.net>
	<30200000.1038946087@titus>
	<Pine.LNX.4.50L.0212031855590.22252-100000@duckman.distro.conectiva>
From: Sean Neakums <sneakums@zork.net>
Date: Wed, 04 Dec 2002 11:28:06 +0000
In-Reply-To: <Pine.LNX.4.50L.0212031855590.22252-100000@duckman.distro.conectiva> (Rik
 van Riel's message of "Tue, 3 Dec 2002 18:56:54 -0200 (BRST)")
Message-ID: <6uk7iqyqex.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, The One True Dave Barry <dave@zork.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

commence  Rik van Riel quotation:

> On Tue, 3 Dec 2002, Martin J. Bligh wrote:
>
>> Assuming the extra time is eaten in Sys, not User,
>
> It's not. It's idle time.  Looks like something very strange
> is going on, vmstat and top output would be nice to have...

Just did a build on 2.4.20-rmap15a.  The wall clock time is lower
than the previous build, but please don't draw any conclusions from
that until I have a 2.4.20 build redone.

real    108m38.567s
user    62m46.480s
sys     29m10.220s

I wasn't sure exactly how you wanted top and vmstat sampled, so I took
them every ten minutes.  ccache stats are in there also.  The first
sample was taken before the build was started, and the last after it
had completed.


Wed Dec  4 09:23:14 GMT 2002
top - 09:23:15 up 12 min,  5 users,  load average: 0.01, 0.12, 0.12
Tasks:  55 total,   1 running,  54 sleeping,   0 stopped,   0 zombie
Cpu(s):   6.1% user,   3.9% system,   0.0% nice,  90.0% idle
Mem:    254580k total,   200680k used,    53900k free,    95272k buffers
Swap:   265064k total,     1620k used,   263444k free,    50180k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
 5411 sneakums  18   0   924  924  736 R  1.0  0.4   0:00.04 top
    1 root       8   0    92   64   40 S  0.0  0.0   0:04.13 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.03 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.00 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kjournald
  121 root       9   0   132    0    0 S  0.0  0.0   0:00.00 dhclient
  190 root       9   0   208  160  160 S  0.0  0.1   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root      10   0  1104  896  512 S  0.0  0.4   0:00.32 nmbd
  211 root       9   0   732  732    0 S  0.0  0.3   0:00.00 smbd
  217 root       9   0   220  220    0 S  0.0  0.1   0:00.01 sshd
  220 daemon     9   0    76   76    0 S  0.0  0.0   0:00.00 atd
  223 root       0   0   296  296  184 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376  376  288 S  0.0  0.1   0:00.01 apache
  230 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.02 bash
  231 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52   52    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  237 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  238 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  239 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  240 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  243 sneakums   9   0   168  168    0 S  0.0  0.1   0:00.03 startx
  244 sneakums   9   0   104  104    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228  228   40 S  0.0  0.1   0:00.02 ssh-agent
  258 sneakums   9   0    72   72    0 S  0.0  0.0   0:00.01 xinit
  259 root      14 -10 73464 7160  676 S  0.0  2.8   0:04.76 XFree86
  262 sneakums   9   0   388  388  224 S  0.0  0.2   0:00.07 ion
  263 sneakums  10   0  1364 1364 1052 S  0.0  0.5   0:00.26 xscreensaver
  266 sneakums  12   0  4676 4668  860 S  0.0  1.8   0:01.66 xterm
  267 sneakums   9   0   304  304    0 S  0.0  0.1   0:00.02 bash
  289 sneakums   9   0  4392 4392  548 S  0.0  1.7   0:00.51 xterm
  290 sneakums   6   0   608  608  304 S  0.0  0.2   0:00.02 bash
  297 sneakums   9   0   220  216  124 S  0.0  0.1   0:00.01 screen
  298 sneakums  10   0   980  980  452 S  0.0  0.4   0:00.79 screen
  299 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.01 bash
  303 sneakums  15   0  1036 1036  684 S  0.0  0.4   0:00.09 bash
  306 root       9   0   224  224    0 S  0.0  0.1   0:00.10 bash
  312 sneakums   8   0   608  608  364 S  0.0  0.2   0:00.02 bash
 5386 sneakums  15   0  1432 1432 1088 S  0.0  0.6   0:00.04 bash
 5409 sneakums  16   0   484  484  408 S  0.0  0.2   0:00.01 tail
cache hit                              0
cache miss                             0
files in cache                     39612
cache size                         256.1 Mbytes
   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 0  0  0   1620  53900  95272  50184    0    2   182    88  181   209  6  4 90
 0  0  0   1620  53900  95272  50184    0    0     0     0  133   123  1  0 99
 0  0  0   1620  53900  95272  50184    0    0     0     0  132    18  0  0 100
 0  0  0   1620  53900  95300  50184    0    0     0    47  135    31  0  0 100
 0  0  0   1620  53900  95300  50184    0    0     0     0  135    17  0  0 100
 0  0  0   1620  53900  95308  50180    0    0     0     8  131    21  0  0 100
 0  0  0   1620  53900  95308  50180    0    0     0     0  125    22  0  0 100
 0  0  0   1620  53900  95308  50180    0    0     0     0  130    18  0  0 100
 0  0  0   1620  53900  95316  50180    0    0     0     8  135    27  0  0 100
 0  0  0   1620  53900  95316  50180    0    0     0     0  130    23  0  0 100

Wed Dec  4 09:24:29 GMT 2002

top - 09:24:30 up 14 min,  5 users,  load average: 0.00, 0.09, 0.10
Tasks:  55 total,   1 running,  54 sleeping,   0 stopped,   0 zombie
Cpu(s):   5.6% user,   3.6% system,   0.0% nice,  90.8% idle
Mem:    254580k total,   200680k used,    53900k free,    95332k buffers
Swap:   265064k total,     1620k used,   263444k free,    50180k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
 5416 sneakums  14   0   928  928  740 R  1.0  0.4   0:00.04 top
    1 root       8   0    92   64   40 S  0.0  0.0   0:04.13 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.03 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.00 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kjournald
  121 root       9   0   132    0    0 S  0.0  0.0   0:00.00 dhclient
  190 root       9   0   208  160  160 S  0.0  0.1   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root      13   0  1104  896  512 S  0.0  0.4   0:00.37 nmbd
  211 root       9   0   732  732    0 S  0.0  0.3   0:00.00 smbd
  217 root       9   0   220  220    0 S  0.0  0.1   0:00.01 sshd
  220 daemon     9   0    76   76    0 S  0.0  0.0   0:00.00 atd
  223 root       4   0   296  296  184 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376  376  288 S  0.0  0.1   0:00.01 apache
  230 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.02 bash
  231 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52   52    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52   52    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  237 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  238 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  239 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  240 www-data   9   0   348  348  268 S  0.0  0.1   0:00.00 apache
  243 sneakums   9   0   168  168    0 S  0.0  0.1   0:00.03 startx
  244 sneakums   9   0   104  104    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228  228   40 S  0.0  0.1   0:00.02 ssh-agent
  258 sneakums   9   0    72   72    0 S  0.0  0.0   0:00.01 xinit
  259 root      10 -10 73464 7160  676 S  0.0  2.8   0:04.85 XFree86
  262 sneakums   9   0   388  388  224 S  0.0  0.2   0:00.07 ion
  263 sneakums   9   0  1364 1364 1052 S  0.0  0.5   0:00.26 xscreensaver
  266 sneakums  11   0  4676 4668  860 S  0.0  1.8   0:01.73 xterm
  267 sneakums   9   0   304  304    0 S  0.0  0.1   0:00.02 bash
  289 sneakums   9   0  4392 4392  548 S  0.0  1.7   0:00.51 xterm
  290 sneakums   8   0   608  608  304 S  0.0  0.2   0:00.02 bash
  297 sneakums   9   0   220  216  124 S  0.0  0.1   0:00.01 screen
  298 sneakums  11   0   980  980  452 S  0.0  0.4   0:00.85 screen
  299 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.01 bash
  303 sneakums  12   0  1040 1040  684 S  0.0  0.4   0:00.09 bash
  306 root       9   0   224  224    0 S  0.0  0.1   0:00.10 bash
  312 sneakums   8   0   608  608  364 S  0.0  0.2   0:00.02 bash
 5386 sneakums  10   0  1432 1432 1088 S  0.0  0.6   0:00.04 bash
 5409 sneakums  10   0   484  484  408 S  0.0  0.2   0:00.01 tail

cache hit                              0
cache miss                             0
files in cache                     39612
cache size                         256.1 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 0  0  0   1620  53900  95332  50184    0    2   166    80  177   196  6  4 91
 0  0  0   1620  53900  95364  50184    0    0     1    51  137   187  6  0 94
 0  0  0   1620  53900  95364  50184    0    0     0     0  130    24  0  0 100
 0  0  0   1620  53900  95372  50184    0    0     0     8  126    27  0  0 100
 0  0  0   1620  53900  95372  50184    0    0     0     0  127    19  0  0 100
 0  0  0   1620  53900  95380  50184    0    0     0     8  127    23  0  0 100
 0  0  0   1620  53900  95380  50184    0    0     0     0  130   172  0  0 99
 0  0  0   1620  53900  95380  50184    0    0     0     0  128    40  0  0 100
 0  0  0   1620  53900  95388  50184    0    0     0     8  135   110  0  1 99
 0  0  0   1620  53628  95388  50184    0    0     0     0  125    57  0  0 99

Wed Dec  4 09:34:48 GMT 2002

top - 09:34:50 up 24 min,  6 users,  load average: 1.61, 1.30, 0.73
Tasks:  65 total,   3 running,  62 sleeping,   0 stopped,   0 zombie
Cpu(s):  27.8% user,  13.1% system,   0.0% nice,  59.0% idle
Mem:    254580k total,   246236k used,     8344k free,    17936k buffers
Swap:   265064k total,     5136k used,   259928k free,   152496k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
17825 sneakums  13   0 10896  10m  544 S  7.5  4.3   0:02.70 make
19269 sneakums  11   0   932  932  736 R  1.9  0.4   0:00.06 top
19371 sneakums  15   0   556  556  372 R  1.9  0.2   0:00.02 cpp0
19369 sneakums  14   0   400  400  320 S  0.9  0.2   0:00.01 cc
    1 root       8   0    92   56   56 S  0.0  0.0   0:04.13 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.04 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:00.19 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.02 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.02 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:00.25 kjournald
  121 root       9   0   132    0    0 S  0.0  0.0   0:00.00 dhclient
  190 root       9   0   148  108  108 S  0.0  0.0   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1076  580  580 S  0.0  0.2   0:00.78 nmbd
  211 root       9   0   860  144  128 S  0.0  0.1   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   216  156  132 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   88   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 72976 6588  232 S  0.0  2.6   0:05.23 XFree86
  262 sneakums   9   0   164  164    0 S  0.0  0.1   0:00.07 ion
  263 sneakums   9   0   480  480  168 S  0.0  0.2   0:00.26 xscreensaver
  266 sneakums   9   0  4104 4096  288 S  0.0  1.6   0:01.80 xterm
  267 sneakums   9   0   304  304    0 S  0.0  0.1   0:00.02 bash
  289 sneakums   9   0  3844 3844    0 S  0.0  1.5   0:00.51 xterm
  290 sneakums   8   0   304  304    0 S  0.0  0.1   0:00.02 bash
  297 sneakums   9   0   220  216  124 S  0.0  0.1   0:00.01 screen
  298 sneakums   9   0   908  908  256 S  0.0  0.4   0:03.36 screen
  299 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.01 bash
  303 sneakums   9   0   620  620  264 S  0.0  0.2   0:00.09 bash
  306 root       9   0   224  224    0 S  0.0  0.1   0:00.10 bash
  312 sneakums   9   0   244  244    0 S  0.0  0.1   0:00.02 bash
 5386 sneakums   9   0   344  344    0 S  0.0  0.1   0:00.04 bash
 5409 sneakums   9   0   144  144   68 S  0.0  0.1   0:00.01 tail
 5420 sneakums   8   0   336  336    0 S  0.0  0.1   0:00.01 bash
 5426 sneakums   9   0   228  228    0 S  0.0  0.1   0:00.07 make
12707 sneakums   9   0   188  188    0 S  0.0  0.1   0:00.01 sh
12711 sneakums   9   0   212  212    0 S  0.0  0.1   0:00.02 make
13783 sneakums   9   0  1376 1376  244 S  0.0  0.5   0:00.65 make
19131 root       9   0  1780 1260 1004 S  0.0  0.5   0:00.04 smbd
19370 sneakums  14   0   404  404  320 R  0.0  0.2   0:00.00 cc

cache hit                           3948
cache miss                             3
called for link                      195
multiple source files                  1
compile failed                        14
preprocessor error                     1
not a C/C++ file                     571
autoconf compile/link                141
unsupported compiler option         2634
no input file                        331
files in cache                     39618
cache size                         256.1 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 2  0  0   5136   8352  17952 152552    0    4   169   217  170   267 28 13 59
 2  0  0   5136   7808  18040 152876    0    0    75   509  174   363 62 28 10
 2  0  0   5144   7192  18108 153196    0    4    74     4  152   268 69 21 10
 2  0  0   5144   6464  18120 153620    0    0    80   512  175   291 65 24 11
 1  0  0   5144   6116  18148 153960    0    0    82     0  144   268 66 22 12
 1  0  0   5144   5652  18216 154316    0    0    86     0  147   300 67 25  8
 1  0  0   5172  11444  18124 147780    0   14    76  1058  201   501 48 24 27
 2  0  0   5180  11444  18120 148168    0    4    72     4  143   284 62 29  9
 2  0  0   5196  11404  18160 148512    0    8    76   604  170   263 65 21 13
 1  0  0   5204  10980  18140 148912    0    4    58     4  145   287 68 24  8

Wed Dec  4 09:45:09 GMT 2002

top - 09:45:10 up 34 min,  6 users,  load average: 1.48, 1.41, 1.04
Tasks:  62 total,   2 running,  60 sleeping,   0 stopped,   0 zombie
Cpu(s):  36.4% user,  17.0% system,   0.0% nice,  46.6% idle
Mem:    254580k total,   247832k used,     6748k free,    22712k buffers
Swap:   265064k total,    10140k used,   254924k free,   162672k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
29202 sneakums  15   0  1168 1168  776 R  2.8  0.5   0:00.03 libtool
29011 sneakums  11   0   928  928  736 R  1.9  0.4   0:00.06 top
    1 root       8   0    92   56   56 S  0.0  0.0   0:04.13 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.14 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:01.30 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.13 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.02 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.10 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:00.48 kjournald
  121 root       8   0   204  180  176 S  0.0  0.1   0:00.02 dhclient
  190 root       9   0   152  112  112 S  0.0  0.0   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1008  512  512 S  0.0  0.2   0:01.05 nmbd
  211 root       9   0   732   16    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   216  156  132 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   88   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 72972 1764  416 S  0.0  0.7   0:05.80 XFree86
  262 sneakums   9   0   164  164    0 S  0.0  0.1   0:00.07 ion
  263 sneakums   9   0   480  480  164 S  0.0  0.2   0:00.28 xscreensaver
  266 sneakums   9   0  4104 4096  288 S  0.0  1.6   0:01.83 xterm
  267 sneakums   9   0   304  304    0 S  0.0  0.1   0:00.02 bash
  289 sneakums   9   0  3844 3844    0 S  0.0  1.5   0:00.51 xterm
  290 sneakums   8   0   304  304    0 S  0.0  0.1   0:00.02 bash
  297 sneakums   9   0   220  216  124 S  0.0  0.1   0:00.01 screen
  298 sneakums   9   0   908  908  256 S  0.0  0.4   0:06.07 screen
  299 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.01 bash
  303 sneakums   9   0   620  620  264 S  0.0  0.2   0:00.11 bash
  306 root       9   0   224  224    0 S  0.0  0.1   0:00.10 bash
  312 sneakums   9   0   244  244    0 S  0.0  0.1   0:00.02 bash
 5386 sneakums   9   0   344  344    0 S  0.0  0.1   0:00.04 bash
 5409 sneakums   9   0   144  144   68 S  0.0  0.1   0:00.02 tail
 5420 sneakums   8   0   336  336    0 S  0.0  0.1   0:00.01 bash
 5426 sneakums   9   0   440  440  212 S  0.0  0.2   0:00.07 make
19131 root       9   0  1024  520  264 S  0.0  0.2   0:00.05 smbd
27133 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.02 sh
27137 sneakums   9   0   736  736  532 S  0.0  0.3   0:00.05 make
28702 sneakums  10   0  1320 1320  544 S  0.0  0.5   0:00.17 make

cache hit                           6611
cache miss                             4
called for link                      312
multiple source files                  2
compile failed                        16
preprocessor error                     2
not a C/C++ file                     827
autoconf compile/link                206
unsupported compiler option         2635
no input file                        535
files in cache                     39620
cache size                         256.1 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0  10140   6364  22720 162720    0    5   320   397  175   341 36 17 47
 1  0  0  10140   5980  22808 163020    0    0   103   391  163   492 53 38  9
 1  0  0  10140   5552  22836 163676    0    0   222     0  152   410 56 38  6
 1  0  0  10140   4040  22868 164076    0    0   142     0  148   426 53 43  4
 1  0  0  10140   4296  22924 164348    0    0   116   468  159   446 55 44  1
 1  0  0  10148   5308  22976 164276    0    4    28     4  128   528 52 45  2
 0  1  3  10156   3556  23304 166480    0    4   444  2026  255  1215 34 31 35
 1  0  0  10268   3320  23096 166556    0   56  6972  3010  340  1414 34 16 50
 1  0  0  10428   3256  22908 167080    0   80  1162  4296  318  2186 23 14 62
 1  0  2  10532   3356  23116 166964    0   52  1760  7592  363  3665 33 24 43

Wed Dec  4 09:55:29 GMT 2002

top - 09:55:30 up 45 min,  6 users,  load average: 1.19, 1.15, 1.08
Tasks:  70 total,   3 running,  67 sleeping,   0 stopped,   0 zombie
Cpu(s):  47.9% user,  15.4% system,   0.0% nice,  36.8% idle
Mem:    254580k total,   245988k used,     8592k free,    16424k buffers
Swap:   265064k total,    12892k used,   252172k free,   167252k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
  209 root       9   0  1108  612  612 S  1.0  0.2   0:01.39 nmbd
  298 sneakums  10   0   912  912  260 S  1.0  0.4   0:06.33 screen
11215 sneakums  10   0   932  932  736 R  1.0  0.4   0:00.03 top
11277 sneakums  16   0   564  564  412 R  1.0  0.2   0:00.01 cpp0
    1 root       8   0   108   72   72 S  0.0  0.0   0:04.13 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.14 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:01.74 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.14 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.03 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.10 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:00.62 kjournald
  121 root       8   0   132  108  104 S  0.0  0.0   0:00.02 dhclient
  190 root       9   0   244  204  204 S  0.0  0.1   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  211 root       9   0   732   16    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   228  168  144 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   88   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 73364 2032 1684 S  0.0  0.8   0:06.23 XFree86
  262 sneakums   9   0   268  160  144 S  0.0  0.1   0:00.08 ion
  263 sneakums   8   0  1216 1136 1124 S  0.0  0.4   0:00.28 xscreensaver
  266 sneakums   9   0  4188 3196  544 S  0.0  1.3   0:01.85 xterm
  267 sneakums   9   0   304  176    0 S  0.0  0.1   0:00.02 bash
  289 sneakums   9   0  3844 3844    0 S  0.0  1.5   0:00.51 xterm
  290 sneakums   8   0   304  304    0 S  0.0  0.1   0:00.02 bash
  297 sneakums   9   0   220  216  124 S  0.0  0.1   0:00.01 screen
  299 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.01 bash
  303 sneakums   9   0   648  648  292 S  0.0  0.3   0:00.11 bash
  306 root       9   0   224  224    0 S  0.0  0.1   0:00.10 bash
  312 sneakums   9   0   244  244    0 S  0.0  0.1   0:00.02 bash
 5386 sneakums   9   0   344  344    0 S  0.0  0.1   0:00.04 bash
 5409 sneakums   9   0   144  144   68 S  0.0  0.1   0:00.02 tail
 5420 sneakums   8   0   336  336    0 S  0.0  0.1   0:00.01 bash
 5426 sneakums   9   0   432  432  204 S  0.0  0.2   0:00.07 make
19131 root       9   0  1024  520  264 S  0.0  0.2   0:00.05 smbd
30865 sneakums   9   0   932  932  744 S  0.0  0.4   0:00.00 sh
30869 sneakums   9   0   728  728  520 S  0.0  0.3   0:00.05 make
30970 sneakums   9   0   904  904  744 S  0.0  0.4   0:00.00 sh
30974 sneakums   9   0   720  720  520 S  0.0  0.3   0:00.12 make
 3694 sneakums   9   0   900  900  528 S  0.0  0.4   0:00.11 make
 8173 sneakums   9   0  1020 1020  780 S  0.0  0.4   0:00.01 sh
 8193 sneakums   9   0   916  916  532 S  0.0  0.4   0:00.20 make
11168 sneakums   9   0   988  988  888 S  0.0  0.4   0:00.00 sh
11174 sneakums   9   0  1020 1020  900 S  0.0  0.4   0:00.00 sh
11175 sneakums  10   0   740  740  532 S  0.0  0.3   0:00.02 make
11276 sneakums  15   0   424  424  340 R  0.0  0.2   0:00.00 xgcc

cache hit                           6842
cache miss                             4
called for link                      335
multiple source files                  2
compile failed                        20
preprocessor error                     2
not a C/C++ file                     827
autoconf compile/link                298
unsupported compiler option         2635
no input file                        535
files in cache                     39620
cache size                         256.1 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0  12892   8592  16424 167260    0    5   271   382  168   295 48 15 37
 2  0  0  12900   8592  16428 167444    0    4     2     4  131   273 80 20  0
 1  0  0  12908   7044  16520 167836    0    4    61   383  154   157 76 12 11
 2  0  0  12916   7564  16540 167944    0    4     0     4  129    41 91  9  0
 1  0  0  12916   6620  16568 168328    0    0    18   400  138    72 91  6  3
 1  0  0  12924   6140  16572 168560    0    4     0     4  131    24 98  2  0
 1  0  0  12924   6228  16576 168696    0    0     2     0  134    34 98  2  0
 1  0  0  12932   6448  16600 168888    0    4     0   468  150    64 89 11  0
 1  0  0  12940   6388  16612 169168    0    4     2     4  131    81 85 14  1
 1  0  0  12940   5712  16648 169404    0    0     8   456  143    69 86 14  0

Wed Dec  4 10:05:48 GMT 2002

top - 10:05:50 up 55 min,  6 users,  load average: 1.21, 1.36, 1.23
Tasks:  69 total,   2 running,  67 sleeping,   0 stopped,   0 zombie
Cpu(s):  49.8% user,  17.3% system,   0.0% nice,  32.9% idle
Mem:    254580k total,   250192k used,     4388k free,    19332k buffers
Swap:   265064k total,    18704k used,   246360k free,   174192k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
29750 sneakums  18   0  1368 1368  380 R  5.6  0.5   0:00.06 cpp0
29699 sneakums  10   0  1388 1388  544 S  1.9  0.5   0:00.19 make
    2 root       9   0     0    0    0 S  0.9  0.0   0:00.19 keventd
29688 sneakums  10   0   932  932  736 R  0.9  0.4   0:00.04 top
29749 sneakums  13   0   404  404  320 S  0.9  0.2   0:00.01 gcc
    1 root       8   0    92   56   56 S  0.0  0.0   0:04.13 init
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:02.59 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.17 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.14 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:00.90 kjournald
  121 root       8   0   132  108  104 S  0.0  0.0   0:00.02 dhclient
  190 root       9   0   144  104  104 S  0.0  0.0   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1064  572  572 S  0.0  0.2   0:01.77 nmbd
  211 root       9   0   732   16    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   216  156  132 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   64   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 73012 1684 1344 S  0.0  0.7   0:06.55 XFree86
  262 sneakums   9   0   192   88   72 S  0.0  0.0   0:00.08 ion
  263 sneakums   9   0   484  404  392 S  0.0  0.2   0:00.29 xscreensaver
  266 sneakums   9   0  4112  516  504 S  0.0  0.2   0:01.89 xterm
  267 sneakums   9   0   304   44    0 S  0.0  0.0   0:00.02 bash
  289 sneakums   9   0  3880  996   36 S  0.0  0.4   0:00.51 xterm
  290 sneakums   8   0   304  164    0 S  0.0  0.1   0:00.02 bash
  297 sneakums   9   0   220  216  124 S  0.0  0.1   0:00.01 screen
  298 sneakums   9   0   944  944  292 S  0.0  0.4   0:07.65 screen
  299 sneakums   9   0   336  336    0 S  0.0  0.1   0:00.01 bash
  303 sneakums   9   0   620  620  264 S  0.0  0.2   0:00.12 bash
  306 root       9   0   224  224    0 S  0.0  0.1   0:00.10 bash
  312 sneakums   9   0   244  244    0 S  0.0  0.1   0:00.02 bash
 5386 sneakums   9   0   344  344    0 S  0.0  0.1   0:00.04 bash
 5409 sneakums   9   0   144  144   68 S  0.0  0.1   0:00.02 tail
 5420 sneakums   8   0   336  336    0 S  0.0  0.1   0:00.01 bash
 5426 sneakums   9   0   460  460  216 S  0.0  0.2   0:00.18 make
19131 root       9   0  1012  508  252 S  0.0  0.2   0:00.05 smbd
21957 sneakums   9   0   932  932  744 S  0.0  0.4   0:00.01 sh
21961 sneakums   9   0   724  724  520 S  0.0  0.3   0:00.05 make
22062 sneakums   9   0   904  904  744 S  0.0  0.4   0:00.00 sh
22066 sneakums   9   0   744  744  528 S  0.0  0.3   0:00.08 make
26644 sneakums   9   0  1316 1316  544 S  0.0  0.5   0:00.24 make
29159 sneakums   9   0  1396 1396  544 S  0.0  0.5   0:00.16 make
29695 sneakums   9   0  1388 1388  544 S  0.0  0.5   0:00.15 make
29748 sneakums  12   0   392  392  320 S  0.0  0.2   0:00.00 gcc

cache hit                           8178
cache miss                            13
called for link                      426
multiple source files                  5
compile failed                        44
preprocessor error                     5
not a C/C++ file                     851
autoconf compile/link                709
unsupported compiler option         2638
no input file                        571
files in cache                     39638
cache size                         256.2 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0  18704   5044  19344 174248    0    6   347   444  172   340 50 17 33
 0  1  0  18712   5852  19384 174572   10    4    75   625  164   235 73 17  9
 1  0  0  18712   6100  19356 175160    0    0   138     0  153   221 66 23 10
 0  1  2  18712   5520  19484 175576    0    0   110  1058  180   186 60 26 14
 2  0  0  18728   4616  19588 175420    0    8   106    12  162   198 56 30 15
 1  0  1  18744   4960  19684 175280    0    8    70     8  142   187 66 28  6
 1  0  1  18808   3452  19640 174500    0   32   238   682  188   272 59 30 11
 1  0  0  18904   4580  19096 177080    0   50   236   186  151   329 80 10  9
 0  1  2  18936   3468  18984 177404    0   20    42  3754  189    99 76 15  9
 1  0  0  18992   5412  18540 174804    0   32   194   922  192   126 50 18 32

Wed Dec  4 10:16:09 GMT 2002

top - 10:16:10 up  1:05,  6 users,  load average: 1.57, 1.37, 1.26
Tasks:  73 total,   3 running,  70 sleeping,   0 stopped,   0 zombie
Cpu(s):  50.8% user,  18.1% system,   0.0% nice,  31.2% idle
Mem:    254580k total,   250644k used,     3936k free,    22548k buffers
Swap:   265064k total,    23800k used,   241264k free,   177324k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
24025 sneakums  11   0  1524 1524  800 S  8.1  0.6   0:00.09 sh
24022 sneakums   9   0  1000 1000  780 S  2.7  0.4   0:00.03 sh
23885 sneakums  11   0   936  936  736 R  1.8  0.4   0:00.06 top
24127 sneakums  18   0   400  400  320 R  0.9  0.2   0:00.01 cc
24128 sneakums  19   0   632  612  372 R  0.9  0.2   0:00.01 cpp0
    1 root       8   0    92   56   56 S  0.0  0.0   0:04.13 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.25 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:03.96 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.21 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.15 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:01.27 kjournald
  121 root       8   0   132    0    0 S  0.0  0.0   0:00.02 dhclient
  190 root       9   0   144   76   76 S  0.0  0.0   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1080  552  552 S  0.0  0.2   0:02.13 nmbd
  211 root       9   0   732    0    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   216  152  152 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   64   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 72992  480  480 S  0.0  0.2   0:06.86 XFree86
  262 sneakums   9   0   164    0    0 S  0.0  0.0   0:00.08 ion
  263 sneakums   9   0   484  264  264 S  0.0  0.1   0:00.29 xscreensaver
  266 sneakums   9   0  4104  448  448 S  0.0  0.2   0:01.96 xterm
  267 sneakums   9   0   304    0    0 S  0.0  0.0   0:00.02 bash
  289 sneakums   9   0  3844    0    0 S  0.0  0.0   0:00.51 xterm
  290 sneakums   8   0   304    0    0 S  0.0  0.0   0:00.02 bash
  297 sneakums   9   0   220   60   60 S  0.0  0.0   0:00.01 screen
  298 sneakums   9   0   908  420  420 S  0.0  0.2   0:09.85 screen
  299 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.01 bash
  303 sneakums   9   0   620  384  324 S  0.0  0.2   0:00.12 bash
  306 root       9   0   224    0    0 S  0.0  0.0   0:00.10 bash
  312 sneakums   9   0   244    0    0 S  0.0  0.0   0:00.02 bash
 5386 sneakums   9   0   344    0    0 S  0.0  0.0   0:00.04 bash
 5409 sneakums   9   0   144  104  104 S  0.0  0.0   0:00.02 tail
 5420 sneakums   8   0   336    0    0 S  0.0  0.0   0:00.01 bash
 5426 sneakums   9   0   456  212  212 S  0.0  0.1   0:00.19 make
19131 root       9   0  1028  332  332 S  0.0  0.1   0:00.05 smbd
 7311 sneakums   9   0   944  756  756 S  0.0  0.3   0:00.00 sh
 7315 sneakums   9   0   740  716  640 S  0.0  0.3   0:00.07 make
22605 sneakums   9   0   680  680  532 S  0.0  0.3   0:00.02 make
22657 sneakums   9   0   680  680  532 S  0.0  0.3   0:00.00 make
22658 sneakums   9   0   944  944  868 S  0.0  0.4   0:00.01 sh
22666 sneakums   9   0   956  956  880 S  0.0  0.4   0:00.00 sh
22667 sneakums   9   0   696  696  532 S  0.0  0.3   0:00.01 make
22668 sneakums   9   0   944  944  872 S  0.0  0.4   0:00.01 sh
23906 sneakums   9   0   956  956  884 S  0.0  0.4   0:00.00 sh
23907 sneakums   9   0   680  680  532 S  0.0  0.3   0:00.01 make
24126 sneakums  15   0   400  400  320 S  0.0  0.2   0:00.00 cc

cache hit                          10527
cache miss                            30
called for link                      443
multiple source files                  6
compile failed                        54
preprocessor error                     5
not a C/C++ file                     936
autoconf compile/link                833
unsupported compiler option         2639
no input file                        590
files in cache                     39672
cache size                         256.9 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0  23792   4308  22556 177384    1    7   365   487  178   364 51 18 31
 2  0  0  23800   3956  22604 177532   26    4    69   403  184   641 46 48  6
 2  0  0  23808   3904  22628 177556    0    4    70     4  141   583 46 51  3
 2  0  0  23816   3996  22688 177612    0    4    46   346  151   599 60 39  1
 2  0  0  23824   4296  22684 177564    0    4    20     4  136   632 51 47  1
 2  0  0  23832   4064  22708 177488    0    4    42     4  128   603 52 47  1
 1  0  0  23840   4360  22748 177500    0    4    54   368  168   626 45 50  5
 1  0  0  23840   4012  22776 177456    0    0    62     0  136   588 50 48  2
 2  0  0  23848   3788  22820 177540    0    4    54   308  159   622 50 47  3
 2  0  0  23856   3940  22812 177304    0    4   172     4  142   597 47 49  4

Wed Dec  4 10:26:28 GMT 2002

top - 10:26:29 up  1:16,  6 users,  load average: 1.30, 1.40, 1.33
Tasks:  66 total,   3 running,  63 sleeping,   0 stopped,   0 zombie
Cpu(s):  51.5% user,  20.1% system,   0.0% nice,  28.5% idle
Mem:    254580k total,   244148k used,    10432k free,    23976k buffers
Swap:   265064k total,    23484k used,   241580k free,   169528k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
  298 sneakums   9   0   908  372  372 S  1.7  0.1   0:11.03 screen
 3068 sneakums  11   0   932  932  736 R  1.7  0.4   0:00.05 top
    1 root       8   0   108   72   72 S  0.0  0.0   0:04.14 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.26 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:04.80 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.24 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.17 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:01.42 kjournald
  121 root       8   0   132    0    0 S  0.0  0.0   0:00.02 dhclient
  190 root       9   0   208  156  156 S  0.0  0.1   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1064  532  532 S  0.0  0.2   0:02.51 nmbd
  211 root       9   0   732    0    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   224  148  132 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   52   52 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 73132  384  384 D  0.0  0.2   0:06.95 XFree86
  262 sneakums   9   0   260   96   96 S  0.0  0.0   0:00.08 ion
  263 sneakums   9   0   740  424  424 S  0.0  0.2   0:00.29 xscreensaver
  266 sneakums   9   0  4112  436  436 D  0.0  0.2   0:01.98 xterm
  267 sneakums   9   0   304    0    0 S  0.0  0.0   0:00.02 bash
  289 sneakums   9   0  3844    0    0 S  0.0  0.0   0:00.51 xterm
  290 sneakums   8   0   304    0    0 S  0.0  0.0   0:00.02 bash
  297 sneakums   9   0   220   60   60 S  0.0  0.0   0:00.01 screen
  299 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.01 bash
  303 sneakums   9   0   624  388  332 S  0.0  0.2   0:00.12 bash
  306 root       9   0   224    0    0 S  0.0  0.0   0:00.10 bash
  312 sneakums   9   0   244    0    0 S  0.0  0.0   0:00.02 bash
 5386 sneakums   9   0   344    0    0 S  0.0  0.0   0:00.04 bash
 5409 sneakums   9   0   144  104  104 S  0.0  0.0   0:00.02 tail
 5420 sneakums   8   0   336    0    0 S  0.0  0.0   0:00.01 bash
 5426 sneakums   9   0   352   92   92 S  0.0  0.0   0:00.29 make
19131 root       9   0  1012  336  336 S  0.0  0.1   0:00.05 smbd
28800 sneakums   9   0   292  292  104 S  0.0  0.1   0:00.00 sh
28804 sneakums   9   0   316  316  108 S  0.0  0.1   0:00.08 make
 1746 sneakums   9   0  1932 1932  308 S  0.0  0.8   0:00.45 make
 3011 sneakums   9   0  1096 1096  788 S  0.0  0.4   0:00.03 sh
 3037 sneakums   9   0   756  756  532 S  0.0  0.3   0:00.03 make
 3049 sneakums   9   0   920  920  764 S  0.0  0.4   0:00.01 sh
 3050 sneakums  14   0   792  792  532 R  0.0  0.3   0:00.08 make
 3084 sneakums  13   0   372  372  288 R  0.0  0.1   0:00.00 sh

cache hit                          11846
cache miss                            44
called for link                      947
multiple source files                 11
compile failed                        79
preprocessor error                     6
not a C/C++ file                     964
autoconf compile/link               1330
unsupported compiler option         2679
no input file                        619
files in cache                     39700
cache size                         257.2 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  1  0  23476   9720  24060 169460    1    7   343   495  176   378 51 20 28
 2  0  0  23484   9596  24048 169896   84    4   130     4  154   219 82 13  4
 1  0  0  23484   9320  23932 170292    0    0    54   703  173   127 78 13  9
 1  0  0  23492   9092  23956 170476    0    4    52     4  139   122 75 17  8
 1  0  0  23492   9180  23836 170748    0    0     6     0  127    93 87 12  1
 1  0  0  23492   9072  23844 170880    0    0    16   494  153   117 82 17  1
 2  0  0  23492   8924  23804 171080    0    0    38     0  132   107 82 16  1
 2  0  0  23492   8764  23864 171176    0    0    20   350  138   120 78 19  3
 1  0  0  23492   8664  23872 171260    0    0     8     0  127   112 86 13  1
 1  0  0  23492   8668  23912 171520    0    0    52     0  135   123 76 20  4

Wed Dec  4 10:36:48 GMT 2002

top - 10:36:50 up  1:26,  6 users,  load average: 1.57, 1.52, 1.41
Tasks:  64 total,   2 running,  62 sleeping,   0 stopped,   0 zombie
Cpu(s):  52.5% user,  21.1% system,   0.0% nice,  26.5% idle
Mem:    254580k total,   245972k used,     8608k free,    24096k buffers
Swap:   265064k total,    23520k used,   241544k free,   172572k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
27945 sneakums  14   0   996  996  776 R  3.9  0.4   0:00.04 sh
    4 root       9   0     0    0    0 S  1.0  0.0   0:05.49 kswapd
27648 sneakums  10   0   932  932  736 R  1.0  0.4   0:00.04 top
    1 root       8   0    92   56   56 S  0.0  0.0   0:04.14 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.28 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.25 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.05 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.18 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:01.73 kjournald
  121 root       8   0   132    0    0 S  0.0  0.0   0:00.02 dhclient
  190 root       9   0   228  160  160 S  0.0  0.1   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1084  564  564 S  0.0  0.2   0:03.06 nmbd
  211 root       9   0   732    0    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   216  152  152 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   64   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 73040  492  492 S  0.0  0.2   0:06.98 XFree86
  262 sneakums   9   0   212   48   48 S  0.0  0.0   0:00.08 ion
  263 sneakums   9   0   536  332  332 S  0.0  0.1   0:00.32 xscreensaver
  266 sneakums   9   0  4108  452  452 S  0.0  0.2   0:01.99 xterm
  267 sneakums   9   0   304    0    0 S  0.0  0.0   0:00.02 bash
  289 sneakums   9   0  3844    0    0 S  0.0  0.0   0:00.51 xterm
  290 sneakums   8   0   304    0    0 S  0.0  0.0   0:00.02 bash
  297 sneakums   9   0   220   60   60 S  0.0  0.0   0:00.01 screen
  298 sneakums   9   0   912  424  424 S  0.0  0.2   0:12.54 screen
  299 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.01 bash
  303 sneakums   9   0   620  384  324 S  0.0  0.2   0:00.13 bash
  306 root       9   0   224    0    0 S  0.0  0.0   0:00.10 bash
  312 sneakums   9   0   244    0    0 S  0.0  0.0   0:00.02 bash
 5386 sneakums   9   0   344    0    0 S  0.0  0.0   0:00.04 bash
 5409 sneakums   9   0   144  104  104 S  0.0  0.0   0:00.02 tail
 5420 sneakums   8   0   336    0    0 S  0.0  0.0   0:00.01 bash
 5426 sneakums   9   0   492  224  224 S  0.0  0.1   0:00.34 make
19131 root       9   0  1056  348  348 S  0.0  0.1   0:00.06 smbd
 3321 sneakums   9   0   944  928  756 S  0.0  0.4   0:00.01 sh
 3325 sneakums   9   0   740  740  532 S  0.0  0.3   0:00.06 make
11042 sneakums   9   0   916  916  756 S  0.0  0.4   0:00.01 sh
11046 sneakums   9   0   732  732  532 S  0.0  0.3   0:00.06 make
14202 sneakums  10   0  1020 1020  532 S  0.0  0.4   0:00.30 make

cache hit                          13697
cache miss                            48
called for link                     1037
multiple source files                 14
compile failed                       116
preprocessor error                     7
not a C/C++ file                    1085
autoconf compile/link               1790
unsupported compiler option         2681
no input file                        637
files in cache                     39708
cache size                         257.2 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 2  0  0  23516   8748  24100 172616    1    7   326   513  175   377 52 21 26
 1  0  0  23516   8040  24156 172692   20    0    41   673  162   637 51 43  5
 1  0  0  23516   8384  24172 172880    4    0    60     0  145   502 54 45  1
 1  0  0  23516   8032  24196 173064    0    0    28   356  149   509 57 42  1
 2  0  0  23516   7900  24204 173176    0    4    16     4  132   487 58 41  1
 1  0  0  23516   7688  24208 173396    0    4    38     4  141   489 60 40  0
 3  0  0  23516   7080  24248 174552    0    4     8   302  154   485 61 39  0
 4  0  0  23564   3688  24484 179004    0   36   622    36  236   564 41 41 18
 0  1  1  23596   4880  24420 177472    2   16    56  4386  239   458 37 32 31
 1  0  0  23612   4700  24292 177720    0   10    88    12  173   444 44 36 20

Wed Dec  4 10:47:09 GMT 2002

top - 10:47:10 up  1:36,  6 users,  load average: 1.52, 1.44, 1.42
Tasks:  64 total,   2 running,  62 sleeping,   0 stopped,   0 zombie
Cpu(s):  52.4% user,  22.8% system,   0.0% nice,  24.8% idle
Mem:    254580k total,   250516k used,     4064k free,    23328k buffers
Swap:   265064k total,    23508k used,   241556k free,   179368k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
19892 sneakums  11   0   728  728  532 S  2.6  0.3   0:00.03 make
19779 sneakums  10   0   928  928  736 R  0.9  0.4   0:00.03 top
19926 sneakums  14   0   916  916  756 S  0.9  0.4   0:00.01 sh
    1 root       8   0    92   56   56 S  0.0  0.0   0:04.14 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.31 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:05.88 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.25 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.06 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.20 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:01.97 kjournald
  121 root       8   0   212  180  180 S  0.0  0.1   0:00.03 dhclient
  190 root       9   0   148   80   80 S  0.0  0.0   0:00.02 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1084  576  576 S  0.0  0.2   0:03.83 nmbd
  211 root       9   0   732    0    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   216  152  152 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   64   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 73148  772  772 D  0.0  0.3   0:07.06 XFree86
  262 sneakums   9   0   252  144  144 S  0.0  0.1   0:00.08 ion
  263 sneakums   9   0  1020  856  852 S  0.0  0.3   0:00.35 xscreensaver
  266 sneakums   9   0  4096  444  444 D  0.0  0.2   0:01.99 xterm
  267 sneakums   9   0   304    0    0 S  0.0  0.0   0:00.02 bash
  289 sneakums   9   0  3844    0    0 S  0.0  0.0   0:00.51 xterm
  290 sneakums   8   0   304    0    0 S  0.0  0.0   0:00.02 bash
  297 sneakums   9   0   220   60   60 S  0.0  0.0   0:00.01 screen
  298 sneakums   9   0   908  436  436 S  0.0  0.2   0:13.70 screen
  299 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.01 bash
  303 sneakums   9   0   620  384  328 S  0.0  0.2   0:00.16 bash
  306 root       9   0   224    0    0 S  0.0  0.0   0:00.10 bash
  312 sneakums   9   0   244    0    0 S  0.0  0.0   0:00.02 bash
 5386 sneakums   9   0   344    0    0 S  0.0  0.0   0:00.04 bash
 5409 sneakums   9   0   144  104  104 S  0.0  0.0   0:00.02 tail
 5420 sneakums   8   0   336    0    0 S  0.0  0.0   0:00.01 bash
 5426 sneakums   9   0   512  432  416 S  0.0  0.2   0:00.48 make
19131 root       9   0  1036  356  356 S  0.0  0.1   0:00.06 smbd
19888 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.00 sh
19928 sneakums  12   0   440  440  364 R  0.0  0.2   0:00.00 md5sum
19929 sneakums  14   0   440  440  364 S  0.0  0.2   0:00.00 grep
19930 sneakums  14   0   444  444  368 S  0.0  0.2   0:00.00 grep

cache hit                          15726
cache miss                            50
called for link                     1156
multiple source files                 20
compile failed                       147
ccache internal error                  1
preprocessor error                    26
not a C/C++ file                    1119
autoconf compile/link               2441
unsupported compiler option         2681
no input file                        680
files in cache                     39712
cache size                         257.3 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  1  0  23496   4224  23336 179776    2    6   309   502  174   387 52 23 25
 1  0  0  23496   4756  23464 178084   36    8   112  1583  193  1040 53 43  3
 1  0  0  23496   4760  23488 178144    0    0    30     0  140   447 51 43  6
 2  0  0  23496   4608  23524 178252    0    0    40   270  162   490 48 42 10
 1  0  0  23496   4744  23520 178400    0    0    56     0  142   470 45 47  8
 1  0  0  23496   4324  23548 178124    0    2    28     2  141   353 62 33  4
 1  0  0  23496   4576  23528 177996    0    0    18   222  151   374 62 37  1
 2  0  0  23496   4560  23524 178004    0    0     0     0  123   374 53 47  0
 1  0  0  23496   4556  23544 178012    0    0     0   160  137   372 61 39  0
 1  0  0  23496   4612  23548 178012    0    0    24     0  135   310 61 37  2

Wed Dec  4 10:57:29 GMT 2002

top - 10:57:30 up  1:47,  6 users,  load average: 1.81, 1.55, 1.43
Tasks:  65 total,   2 running,  63 sleeping,   0 stopped,   0 zombie
Cpu(s):  52.6% user,  24.0% system,   0.0% nice,  23.4% idle
Mem:    254580k total,   251140k used,     3440k free,    27512k buffers
Swap:   265064k total,    23492k used,   241572k free,   174308k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
29970 sneakums  14   0   852  852  676 R  7.9  0.3   0:00.11 man
29984 sneakums  13   0   932  932  736 R  1.0  0.4   0:00.03 top
    1 root       8   0   108   72   72 S  0.0  0.0   0:04.14 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.33 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:06.34 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.27 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.07 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.21 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:02.21 kjournald
  121 root       8   0   200   68   68 S  0.0  0.0   0:00.03 dhclient
  190 root       9   0   240  172  172 S  0.0  0.1   0:00.03 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1084  552  552 S  0.0  0.2   0:04.37 nmbd
  211 root       9   0   732    0    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   228  152  128 S  0.0  0.1   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   64   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 73272 1704 1704 S  0.0  0.7   0:07.26 XFree86
  262 sneakums   8   0   248  124  108 S  0.0  0.0   0:00.08 ion
  263 sneakums   9   0   928  812  808 S  0.0  0.3   0:00.36 xscreensaver
  266 sneakums   9   0  4144  516  516 S  0.0  0.2   0:02.03 xterm
  267 sneakums   9   0   304    0    0 S  0.0  0.0   0:00.02 bash
  289 sneakums   9   0  3844    0    0 S  0.0  0.0   0:00.51 xterm
  290 sneakums   8   0   304    0    0 S  0.0  0.0   0:00.02 bash
  297 sneakums   9   0   220   60   60 S  0.0  0.0   0:00.01 screen
  298 sneakums   9   0   920  420  420 S  0.0  0.2   0:15.12 screen
  299 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.01 bash
  303 sneakums  10   0   648  412  356 S  0.0  0.2   0:00.16 bash
  306 root       9   0   224    0    0 S  0.0  0.0   0:00.10 bash
  312 sneakums   9   0   244    0    0 S  0.0  0.0   0:00.02 bash
 5386 sneakums   9   0   344    0    0 S  0.0  0.0   0:00.04 bash
 5409 sneakums   9   0   144  104  104 S  0.0  0.0   0:00.02 tail
 5420 sneakums   8   0   336    0    0 S  0.0  0.0   0:00.01 bash
 5426 sneakums   9   0   528  364  348 S  0.0  0.1   0:00.59 make
19131 root       9   0  1028  348  348 S  0.0  0.1   0:00.06 smbd
28780 sneakums   9   0   944  944  756 S  0.0  0.4   0:00.01 sh
28784 sneakums   9   0   740  740  532 S  0.0  0.3   0:00.05 make
29955 sneakums  10   0   708  708  532 S  0.0  0.3   0:00.02 make
29969 sneakums  11   0   904  904  744 S  0.0  0.4   0:00.01 sh
29971 sneakums  11   0   368  368  312 S  0.0  0.1   0:00.00 col
29972 sneakums  11   0   360  360  288 S  0.0  0.1   0:00.00 cat

cache hit                          17482
cache miss                            51
called for link                     1328
multiple source files                 25
compile failed                       258
ccache internal error                  1
preprocessor error                    35
not a C/C++ file                    1146
autoconf compile/link               3500
unsupported compiler option         2684
no input file                        711
files in cache                     39714
cache size                         257.4 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 1  0  0  23484   3488  27520 174376    2    6   294   498  173   393 53 24 23
 1  0  0  23484   3620  27648 173912   20    4  1680   557  293   489 31 18 51
 1  0  0  23488   3440  27616 173836    0    8   568     8  252   412 28 26 46
 0  1  0  23488   3556  27692 173760    0    6   690   430  311   471 35 19 45
 2  0  0  23484   4340  27952 172284    0   20   832   426  300   572 30 22 47
 2  0  0  23484   3904  28008 172776    0    2   128     2  139   741 50 46  4
 0  1  2  23484   3652  28124 173728    0    8   284  1676  197   993 36 44 19
 0  0  0  23484   4524  28060 172240    0    8     2   374  163   299 51 36 12
 2  0  0  23484   4324  28052 172224    0    0     0     0  135   177 47 15 37
 2  0  0  23484   4448  28072 172096    0    0    12   176  140   310 58 39  3

Wed Dec  4 11:07:50 GMT 2002

top - 11:07:54 up  1:57,  6 users,  load average: 1.68, 1.53, 1.44
Tasks:  63 total,   1 running,  62 sleeping,   0 stopped,   0 zombie
Cpu(s):  52.6% user,  24.7% system,   0.0% nice,  22.7% idle
Mem:    254580k total,   251140k used,     3440k free,    23052k buffers
Swap:   265064k total,    24864k used,   240200k free,   178004k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
  357 sneakums  14   0  1864 1548  524 D  2.2  0.6   0:07.41 rsync
  359 sneakums  12   0  2664 2404 2116 S  1.5  0.9   0:04.67 rsync
  361 sneakums  11   0   928  928  736 R  1.5  0.4   0:00.04 top
  358 sneakums  10   0  2652 2436 2012 S  0.7  1.0   0:00.86 rsync
    1 root       8   0   108   72   72 S  0.0  0.0   0:04.14 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.38 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:07.30 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.30 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.07 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.01 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.27 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:02.54 kjournald
  121 root       8   0   132    0    0 S  0.0  0.0   0:00.03 dhclient
  190 root       9   0   144   48   48 S  0.0  0.0   0:00.03 syslogd
  193 root       9   0   828    0    0 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    0    0 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    0    0 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1056  520  520 S  0.0  0.2   0:04.91 nmbd
  211 root       9   0   732    0    0 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    0    0 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    76    0    0 S  0.0  0.0   0:00.00 atd
  223 root       8   0   200   88   88 S  0.0  0.0   0:00.01 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    0    0 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    0    0 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    0    0 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    0    0 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    0    0 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   228   64   64 S  0.0  0.0   0:00.02 ssh-agent
  258 sneakums   9   0    72    0    0 S  0.0  0.0   0:00.01 xinit
  259 root       5 -10 73020  408  408 D  0.0  0.2   0:07.28 XFree86
  262 sneakums   8   0   248   84   84 S  0.0  0.0   0:00.08 ion
  263 sneakums   9   0   608  380  380 S  0.0  0.1   0:00.36 xscreensaver
  266 sneakums   9   0  4032  348  348 D  0.0  0.1   0:02.03 xterm
  267 sneakums   9   0   304    0    0 S  0.0  0.0   0:00.02 bash
  289 sneakums   9   0  3844    0    0 S  0.0  0.0   0:00.51 xterm
  290 sneakums   8   0   304    0    0 S  0.0  0.0   0:00.02 bash
  297 sneakums   9   0   220   60   60 S  0.0  0.0   0:00.01 screen
  298 sneakums   9   0   908  420  420 S  0.0  0.2   0:16.48 screen
  299 sneakums   9   0   336    0    0 S  0.0  0.0   0:00.01 bash
  303 sneakums   9   0   620  384  332 S  0.0  0.2   0:00.16 bash
  306 root       9   0   224    0    0 S  0.0  0.0   0:00.10 bash
  312 sneakums   9   0   244    0    0 S  0.0  0.0   0:00.02 bash
 5386 sneakums   9   0   344    0    0 S  0.0  0.0   0:00.04 bash
 5409 sneakums   9   0   144  104  104 S  0.0  0.0   0:00.02 tail
 5420 sneakums   8   0   336    0    0 S  0.0  0.0   0:00.01 bash
 5426 sneakums   9   0   320    0    0 S  0.0  0.0   0:00.61 make
19131 root       9   0  1016  236  236 S  0.0  0.1   0:00.06 smbd
 5131 sneakums   9   0   188    0    0 S  0.0  0.0   0:00.01 sh
 5138 sneakums   9   0   340  100  100 S  0.0  0.0   0:00.15 make

cache hit                          19053
cache miss                            57
called for link                     1523
multiple source files                 26
compile failed                       344
ccache internal error                  1
preprocessor error                    68
not a C/C++ file                    1208
autoconf compile/link               4500
unsupported compiler option         2744
no input file                        729
files in cache                     39726
cache size                         257.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 0  1  0  24912   3440  23188 177800    2    6   302   510  174   400 53 25 23
 0  1  0  25024   3440  22980 178036    8   56  1147  2504  288  1670  6 14 79
 0  1  1  25168   3324  22632 178416   18   72  1150  2196  331  1294  5 18 76
 0  2  2  25184   3524  22736 177900   42    8   319  3538  297   246  1  4 94
 0  2  0  25240   3440  22880 177480   66   28  1422    38  306   691  6  4 90
 0  1  0  25312   3440  23160 177704   24   48  1917   454  407  1681  8 14 78
 0  1  0  25432   3540  22780 178012    8   60  2152  3297  407  1788  8 11 80
 0  1  1  25584   3440  22876 177704   64   76  2888   890  509  1648  9 18 73
 0  1  0  25616   3696  22760 177840   14   16   542  4134  296   141  2  2 96
 1  0  0  25680   3500  22756 178060   10   32   580    32  282  1076  1  6 93

Wed Dec  4 11:18:15 GMT 2002

top - 11:18:16 up  2:07,  6 users,  load average: 0.07, 0.62, 1.08
Tasks:  58 total,   2 running,  56 sleeping,   0 stopped,   0 zombie
Cpu(s):  49.9% user,  23.6% system,   0.0% nice,  26.5% idle
Mem:    254580k total,   251096k used,     3484k free,    18292k buffers
Swap:   265064k total,    23160k used,   241904k free,   184688k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
  259 root      13 -10 73316 1152 1152 S  0.9  0.5   0:08.93 XFree86
13467 sneakums  13   0  1740 1740 1216 R  0.9  0.7   0:00.20 ssh
13470 sneakums  13   0   924  924  736 R  0.9  0.4   0:00.03 top
    1 root       8   0    92   56   56 S  0.0  0.0   0:04.14 init
    2 root       9   0     0    0    0 S  0.0  0.0   0:00.44 keventd
    3 root      19  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd_CPU0
    4 root       9   0     0    0    0 S  0.0  0.0   0:08.51 kswapd
    5 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kscand
    6 root       9   0     0    0    0 S  0.0  0.0   0:00.42 bdflush
    7 root       9   0     0    0    0 S  0.0  0.0   0:00.08 kupdated
    8 root       9   0     0    0    0 S  0.0  0.0   0:00.00 i2oevtd
    9 root       9   0     0    0    0 S  0.0  0.0   0:00.02 kjournald
   44 root       9   0     0    0    0 S  0.0  0.0   0:00.00 khubd
   80 root       9   0     0    0    0 S  0.0  0.0   0:00.00 kjournald
   81 root       9   0     0    0    0 S  0.0  0.0   0:00.28 kjournald
   82 root       9   0     0    0    0 S  0.0  0.0   0:02.85 kjournald
  121 root       8   0   244  116  116 S  0.0  0.0   0:00.03 dhclient
  190 root       9   0   180  112  112 S  0.0  0.0   0:00.04 syslogd
  193 root       9   0   828    4    4 S  0.0  0.0   0:00.18 klogd
  201 root       9   0    64    4    4 S  0.0  0.0   0:00.00 inetd
  205 root       9   0    88    4    4 S  0.0  0.0   0:00.01 lpd
  209 root       9   0  1104  588  588 S  0.0  0.2   0:05.16 nmbd
  211 root       9   0   732    4    4 S  0.0  0.0   0:00.00 smbd
  217 root       9   0   220    4    4 S  0.0  0.0   0:00.01 sshd
  220 daemon     9   0    92   20   20 S  0.0  0.0   0:00.00 atd
  223 root       8   0   216  152  152 S  0.0  0.1   0:00.02 cron
  227 root       9   0   376   52   52 S  0.0  0.0   0:00.01 apache
  230 sneakums   9   0   336    4    4 S  0.0  0.0   0:00.02 bash
  231 root       9   0    52    4    4 S  0.0  0.0   0:00.00 getty
  232 root       9   0    52    4    4 S  0.0  0.0   0:00.01 getty
  233 root       9   0    52    4    4 S  0.0  0.0   0:00.00 getty
  234 root       9   0    52    4    4 S  0.0  0.0   0:00.00 getty
  235 root       9   0    52    4    4 S  0.0  0.0   0:00.00 getty
  236 www-data   9   0   348    4    4 S  0.0  0.0   0:00.00 apache
  237 www-data   9   0   348    4    4 S  0.0  0.0   0:00.00 apache
  238 www-data   9   0   348    4    4 S  0.0  0.0   0:00.00 apache
  239 www-data   9   0   348    4    4 S  0.0  0.0   0:00.00 apache
  240 www-data   9   0   348    4    4 S  0.0  0.0   0:00.00 apache
  243 sneakums   9   0   168    4    4 S  0.0  0.0   0:00.03 startx
  244 sneakums   9   0   104    4    4 S  0.0  0.0   0:00.01 vlock
  245 sneakums   9   0   372  272  272 S  0.0  0.1   0:00.02 ssh-agent
  258 sneakums   9   0    72    4    4 S  0.0  0.0   0:00.01 xinit
  262 sneakums   8   0   380  288  288 S  0.0  0.1   0:00.08 ion
  263 sneakums  10   0   856  656  656 S  0.0  0.3   0:00.43 xscreensaver
  266 sneakums  10   0  4576 1064 1060 S  0.0  0.4   0:02.16 xterm
  267 sneakums   9   0   304    4    4 S  0.0  0.0   0:00.02 bash
  289 sneakums  12   0  4672 1404 1404 S  0.0  0.6   0:00.75 xterm
  290 sneakums   9   0   636  468  432 S  0.0  0.2   0:00.03 bash
  297 sneakums   9   0   220   64   64 S  0.0  0.0   0:00.01 screen
  298 sneakums   9   0   980  496  496 S  0.0  0.2   0:18.25 screen
  299 sneakums   9   0   336    4    4 S  0.0  0.0   0:00.01 bash
  303 sneakums  10   0   620  384  328 S  0.0  0.2   0:00.16 bash
  306 root       9   0   224    4    4 S  0.0  0.0   0:00.10 bash
  312 sneakums   6   0   628  516  472 S  0.0  0.2   0:00.02 bash
 5386 sneakums   9   0   344    4    4 S  0.0  0.0   0:00.04 bash
 5409 sneakums   9   0   144  104  104 S  0.0  0.0   0:00.02 tail
 5420 sneakums   8   0   336    4    4 S  0.0  0.0   0:00.01 bash
19131 root       9   0  1028  356  356 S  0.0  0.1   0:00.08 smbd

cache hit                          20127
cache miss                            59
called for link                     1556
multiple source files                 28
compile failed                       344
ccache internal error                  1
preprocessor error                    68
not a C/C++ file                    1220
autoconf compile/link               4502
unsupported compiler option         2751
no input file                       1146
files in cache                     39730
cache size                         257.5 Mbytes

vmstat 2 10

   procs                      memory      swap          io     system      cpu
 r  b  w   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id
 0  0  0  23152   3536  18300 184736    3    7   358   554  177   397 50 24 26
 0  0  0  23152   3540  18316 184628    4    4     4    59  165   134  1  0 99
 0  0  0  23152   3540  18316 184628    0    0     0     0  195   161  0  0 100
 0  0  0  23152   3540  18316 184628    0    0     0     0  175   176  0  1 99
 0  0  0  23152   3540  18324 184628    2    0     2     8  159   155  0  0 100
 0  0  0  23152   3540  18324 184628    0    0     0     0  154   121  1  1 98
 0  0  0  23152   3540  18332 184628    0    0     0     8  156   131  1  0 99
 0  0  0  23152   3540  18332 184628    0    0     0     0  142    62  0  0 100
 0  0  0  23152   3540  18332 184628    0    0     0     0  152   112  0  0 100
 0  0  0  23152   3540  18340 184628    0    0     0     8  163   168  0  0 100


-- 
 /                          |
[|] Sean Neakums            |  Questions are a burden to others;
[|] <sneakums@zork.net>     |      answers a prison for oneself.
 \                          |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
