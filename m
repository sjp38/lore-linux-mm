Date: Sun, 4 Aug 2002 10:16:11 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: how not to write a search algorithm
In-Reply-To: <3D4CE74A.A827C9BC@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0208041015350.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Aug 2002, Andrew Morton wrote:

>                head                           tail
> active_list:   <800M of ZONE_NORMAL> <200M of ZONE_HIGHMEM>
> inactive_list:          <1.5G of ZONE_HIGHMEM>
>
> now, somebody does a GFP_KERNEL allocation.
>
> uh-oh.

> Per-zone LRUs will fix it up.  We need that anyway, because a ZONE_NORMAL
> request will bogusly refile, on average, memory_size/800M pages to the
> head of the inactive list, thus wrecking page aging.
>
> Alan's kernel has a nice-looking implementation.  I'll lift that out
> next week unless someone beats me to it.

Good to hear that you found this one ;)

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
