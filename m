Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA29696
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 18:02:36 -0500
Date: Wed, 25 Nov 1998 23:59:17 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: rw_swap_page() and swapin readahead
In-Reply-To: <199811252219.WAA05712@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981125235645.17460B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 1998, Stephen C. Tweedie wrote:
> On Wed, 25 Nov 1998 23:02:30 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > it appears that rw_swap_page() needs a small change to be
> > able to do asynchonous swapin.
> 
> > On line 128:
> > 		if (!wait) {
> > 			set_bit(PG_free_after, &page->flags);
			set_bit(PG_decr_after, &page->flags);
			set_bit(PG_swap_unlock_after, &page->flags);
			atomic_inc(&nr_async_pages);
> > 		}
> 
> The PG_free_after bit is there only to mark that increment, so that
> the page count is decremented again (asynchronously) once the IO is
> complete and no sooner. 

Then what does the PG_decr_after do? It seems like there
are two flags to do the same thing... I'm curious :)

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
