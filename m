Date: Wed, 4 Sep 2002 16:42:59 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: nonblocking-vm.patch
In-Reply-To: <3D76549B.3C53D0AC@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209041640171.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2002, Andrew Morton wrote:

> We do need something in there to prevent kswapd from going berzerk.

Agreed, but it can be a lot simpler than your idea.

As long as we can free up to zone->pages_high pages,
we don't need to throttle since we're succeeding in
keeping enough pages free to not be woken up for a
while.

If we don't succeed in freeing enough pages, that is
because the pages are still under IO and haven't hit
the disk yet.  In this case, we need to wait for the
IO to finish, or at least for some of the pages to
get cleaned.  We can do this by simply refusing to
scan that zone again for a number of jiffies, say
1/4 of a second.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
