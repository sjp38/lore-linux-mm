Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA05817
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 10:16:00 -0500
Date: Thu, 3 Dec 1998 15:44:07 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <199812021733.RAA04470@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981203153155.216A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 1998, Stephen C. Tweedie wrote:
> On 01 Dec 1998 18:20:49 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
> said:
> 
> > Yes. something like that. Since nobody asked pages to swap in (we
> > decided to swap them in) it looks like nobody frees them. :)
> > So we should free them somewhere, probably.
> 
> I think read_swap_page_async should be acting as a lookup on the page
> cache, so the page it returns is guaranteed to have an incremented
> reference count.  You'll need to free_page() it just after the
> read_swap_page_async() call to get the expected behaviour.

I have now included the free_page() and things seem to work
out fine. In version 6 of the swapin readahead patch I also
fixed the swap_cache_find_* statistics. We really should make
those available through /proc/sys/vm/swapcache (and writable
so we can test the stats over a certain period of time).

Zlatko's hogmem.c gives pretty decent performance now, but I
guess it could be better by always doing readahead regardless
of whether the page is in memory or not...

OTOH, I have observed swapin rates of 5000+ swaps a second, or
3000 in/out :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
