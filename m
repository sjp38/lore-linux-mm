Date: Thu, 19 Apr 2001 18:46:00 +0200 (MEST)
From: Simon Derr <Simon.Derr@imag.fr>
Subject: Re: Want to allocate almost all the memory with no swap
In-Reply-To: <de3udt4pee8l6lrr2k33h65m1b4srb74ek@4ax.com>
Message-ID: <Pine.LNX.4.21.0104191833070.10083-100000@guarani.imag.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: Simon Derr <Simon.Derr@imag.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >Well, I have removed as many processes deamons as I could, and there are
> >not many left.
> >But under both 2.4.2 and 2.2.17 (with swap on)I get, when I run my
> >program:
> >
> >mlockall: Cannot allocate memory
> 
> Hrm? Can you trim the consumption a bit - try cutting a big chunk out,
> like 64 Mb, and see if it works then?
> 
If I ask much less memory it works.. but has no interest.

In fact I a call mlockall() _before_ doing my big malloc, it works even
when I ask 240 megs, but:
-Under 2.2.17, quickly the kernel kills my process
-Under 2.4.2, kswapd again eats the CPU:

Mem:   254692K av,  252868K used,    1824K free,       0K shrd,  88K buff
Swap:  313256K av,    5476K used,  307780K free             4204K cached

  PID USER     PRI  NI  SIZE  RSS SHARE STAT  LIB %CPU %MEM   TIME COMMAND
    3 root      14   0     0    0     0 RW      0 47.4  0.0  20:50 kswapd
 1277 root      14   0  241M 241M   968 R       0 46.8 96.8   0:12 loop
    5 root       9   0     0    0     0 SW      0  5.3  0.0   0:23 bdflush
 1278 root      10   0   468  404   404 R       0  0.3  0.1   0:00 top


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
