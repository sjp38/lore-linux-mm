Date: Sat, 20 Jul 2002 13:11:12 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH][1/2] return values shrink_dcache_memory etc
In-Reply-To: <Pine.LNX.4.44L.0207201639500.12241-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.44.0207201308180.1419-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>


On Sat, 20 Jul 2002, Rik van Riel wrote:
>
> this patch, against current 2.5.27, builds on the patch that let
> kmem_cache_shrink return the number of pages freed. This value
> is used as the return value for shrink_dcache_memory and friends.

I disagree with the whole approach of having shrink_cache() return the
number of pages free.

The number is meaningless, since it has nothing to do with the actual
memory zones that are under pressure (right now, the memory zone is almost
always ZONE_NORMAL, which is correct, but that's just pure luck rather
than anything fundamental).

I'd be much more interested in the "put the cache pages on the dirty list,
and have memory pressure push them out in LRU order" approach. Somebody
already had preliminary patches.

That gets _rid_ of dcache_shrink() and friends, instead of making them
return meaningless numbers.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
