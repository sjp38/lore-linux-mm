Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA29267
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 17:10:13 -0500
Date: Wed, 25 Nov 1998 23:02:30 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: rw_swap_page() and swapin readahead
Message-ID: <Pine.LNX.3.96.981125225829.15920C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Stephen,

it appears that rw_swap_page() needs a small change to be
able to do asynchonous swapin.

On line 128:
		if (!wait) {
			set_bit(PG_free_after, &page->flags);
			...
		}
			
We probably want to loose the line with PG_free_after, even
on normal swapout (or is it already gone in 2.1.130-pre3?).

If I misunderstood the code, I'll happily learn a bit :)

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
