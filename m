Date: Fri, 21 Apr 2000 13:02:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: swapping from pagecache?
In-Reply-To: <852568C8.00490F70.00@raylex-gh01.eo.ray.com>
Message-ID: <Pine.LNX.4.21.0004211250220.10921-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: Cacophonix <cacophonix@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Apr 2000 Mark_H_Johnson.RTS@raytheon.com wrote:

> My experience so far w/ Linux 2.2 (both .10 and .14) is that it
> is "lazy" in swapping and paging. It attempts to keep memory
> fully utilized. There are costs and benefits of such an
> approach. Your application may do better with such tuning. My
> experience is that a "rogue" program, one that allocates a lot
> of virtual memory and keeps it busy, can cause serious
> degradation to a Linux system. Let me use an example a prime
> number finder using Eratosthenes sieve. It walks through memory
> setting every second, third, fifth, seventh, and so on item in a
> large array, marking it as "non-prime". It generates a HUGE
> number of dirty pages. Since physical memory limits aren't
> imposed on Linux 2.2, this program gobbles up all physical
> memory. Most, if not all other jobs get swapped, and system
> performance is awful. Running this same program on a VMS system,
> properly tuned, would result in slower performance for the
> sieve, higher paging rates, but still reasonable interactive
> performance. I would like to see Linux in 2001 have better
> performance than VMS did in the early 80's.

I'm working on this and believe that by making swapping less
lazy and being less friendly to big tasks. I've been thinking
about these problems for a while now and will start writing
the code this saturday or at the latest monday.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
