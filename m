Date: Thu, 29 Aug 2002 18:46:15 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] low-latency zap_page_range()
In-Reply-To: <3D6E9084.820B2608@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0208291845060.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Robert Love <rml@tech9.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Aug 2002, Andrew Morton wrote:

> > So we know it is held forever and a day... but is there contention?
>
> I'm sure there is, but nobody has measured the right workload.
>
> Two CLONE_MM threads, one running mmap()/munmap(), the other trying
> to fault in some pages.  I'm sure someone has some vital application
> which does exactly this.  They always do :(

Can't fix this one.  The mmap()/munmap() needs to have the
mmap_sem for writing as long as its setting up or tearing
down a VMA while the pagefault path takes the mmap_sem for
reading.

It might be fixable in some dirty way, but I doubt that'll
ever be worth it.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
