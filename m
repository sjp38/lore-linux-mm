Date: Thu, 11 May 2000 18:38:05 +0100
From: Steve Dodd <steved@loth.demon.co.uk>
Subject: Re: [PATCH] Recent VM fiasco - fixed
Message-ID: <20000511183805.A2777@loth.demon.co.uk>
References: <m366smx3qy.fsf@austin.jhcloos.com> <Pine.LNX.4.10.10005101708590.1489-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10005101708590.1489-100000@penguin.transmeta.com>; from Linus Torvalds on Wed, May 10, 2000 at 05:16:05PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "James H. Cloos Jr." <cloos@jhcloos.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, May 10, 2000 at 05:16:05PM -0700, Linus Torvalds wrote:

[..]
> Just the dirty buffer handling made quite an enormous difference, so
> please do test this if you hated earlier pre7 kernels.

I definitely hate pre7-9.

For various reasons, I'm stuck on a 16Mb box right now. I just tried to start
dselect[0], and it got killed. It's completely repeatable, and running vmstat
shows that something demented is happening:

frodo:~$ vmstat 1 # and then start dselect on another terminal
 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 0 0 0  2508  6544   196  5124   6   4   94    9  137   56  40   5  55
 0 0 0  2508  6524   196  5140   0   0   16    0  134    4   0   2  98
 0 0 0  2508  6524   196  5140   0   0    0    0  106    2   0   2  98
 0 0 0  2508  6520   200  5140   0   0    1    0  112    6   0   2  98
 0 0 0  2508  6200   204  5224  16   0   77    0  125   29   4   4  92
 0 0 0  2508  6200   204  5224   0   0    0    0  103    2   0   2  98
 1 0 0  2508  5332   212  5504   0   0  285    0  117   21  42   4  54
 1 0 0  2508  3748   216  6004   0   0  501    0  119   24  83   7  11
 1 0 0  2508  2664   220  6388   0   0  389   69  164   20  55   5  40
 1 0 0  2508   964   224  7020   0   0  631    0  117   15  83   6  11
 1 0 0  2508   364   216  6692   0   0  341    0  113   22  81  15   5
 1 0 0  2504   288   208  5900   0   0  512    0  114   18  78  22   0
 1 0 0  2504   364   112  5068   0   0  514    0  114   25  77  18   5
 1 0 1  2504   252    72  4416   0   0  483   12  137   47  73  15  13
 1 0 0  2504   264    68  4448   0   0  511   13  147   77  32  20  48
VM: killing process dselect
 0 2 0  2504  8044    76  3960 176   0  803    0  220  137  16  23  61
 0 0 0  2504  8032    76  3964   0   0    2    0  106    8   0   2  98
 0 0 0  2504  8032    76  3964   0   0    1    0  105    6   0   2  98

I'm not an "mm person", but that doesn't look optimal to me.

The box does have a reasonable amount of swap:

frodo:~$ cat /proc/swaps
Filename			Type		Size	Used	Priority
/dev/hdc2                       partition	18140	2480	-1
/dev/hdc4                       partition	50396	0	-2


[0] so I could install the libbfd header files to compile kdb to poke at the
loop device lock-up stuff so I can use loop for testing ntfs stuff.. I'm
stuck in a maze of twisty kernel bugs, none alike..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
