Date: Sat, 20 Jul 2002 17:41:39 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH][1/2] return values shrink_dcache_memory etc
In-Reply-To: <Pine.LNX.4.44.0207201308180.1419-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.44L.0207201740580.12241-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Jul 2002, Linus Torvalds wrote:
> On Sat, 20 Jul 2002, Rik van Riel wrote:
> >
> > this patch, against current 2.5.27, builds on the patch that let
> > kmem_cache_shrink return the number of pages freed. This value
> > is used as the return value for shrink_dcache_memory and friends.

> I'd be much more interested in the "put the cache pages on the dirty list,
> and have memory pressure push them out in LRU order" approach. Somebody
> already had preliminary patches.
>
> That gets _rid_ of dcache_shrink() and friends, instead of making them
> return meaningless numbers.

OK, I'll try to forward-port Ed's code to do that from 2.4 to 2.5
this weekend...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
