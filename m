Date: Sun, 4 Aug 2002 23:55:02 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: how not to write a search algorithm
In-Reply-To: <3D4DEA4B.4BAB65FB@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0208042354100.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Aug 2002, Andrew Morton wrote:

> Well I think we'll need a per-cpu-pages thing to amortise zone->lock
> contention anyway.  So what we can do is:
>
> 	fill_up_the_per_cpu_buffer(GFP_KERNEL);		/* disables preemption */
> 	spin_lock(lock);
> 	allocate(GFP_ATOMIC);
> 	spin_unlock(lock);
> 	preempt_enable();
>
> We also prevent interrupt-time allocations from
> stealing the final four pages from the per-cpu buffer.
>
> The allocation is guaranteed to succeed, yes?   Can use
> it for ratnodes as well.

Yes, that would work.

One page for the process, one page table page, one ratcache page
and one pte chain page ... anything else ?

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
