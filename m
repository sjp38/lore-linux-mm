Date: Thu, 19 Apr 2001 18:56:16 +0200 (MEST)
From: Simon Derr <Simon.Derr@imag.fr>
Subject: Re: Want to allocate almost all the memory with no swap
In-Reply-To: <Pine.LNX.4.21.0104191833070.10083-100000@guarani.imag.fr>
Message-ID: <Pine.LNX.4.21.0104191851180.10083-100000@guarani.imag.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Derr <Simon.Derr@imag.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Simon Derr wrote:

> If I ask much less memory it works.. but has no interest.
> 
> In fact I a call mlockall() _before_ doing my big malloc, it works even
> when I ask 240 megs, but:
> -Under 2.2.17, quickly the kernel kills my process
> -Under 2.4.2, kswapd again eats the CPU:
> 
> Mem:   254692K av,  252868K used,    1824K free,       0K shrd,  88K buff
> Swap:  313256K av,    5476K used,  307780K free             4204K cached
> 
>   PID USER     PRI  NI  SIZE  RSS SHARE STAT  LIB %CPU %MEM   TIME COMMAND
>     3 root      14   0     0    0     0 RW      0 47.4  0.0  20:50 kswapd
>  1277 root      14   0  241M 241M   968 R       0 46.8 96.8   0:12 loop
>     5 root       9   0     0    0     0 SW      0  5.3  0.0   0:23 bdflush
>  1278 root      10   0   468  404   404 R       0  0.3  0.1   0:00 top
> 

Actually this is what happens under 2.4.2 :
when I launch the program, during about one minute kswapd eats 50% cpu,
and bdflush takes 2-5% cpu,
One minute later approx, they both stop eating the cpu and my process gets
almost 100% of the cpu (a PIII 733).

The same happens if I kill and launch my program a second time.

Sorry for the pollution I bring to your mailing list...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
