Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA00988
	for <linux-mm@kvack.org>; Sun, 12 Jul 1998 21:30:48 -0400
Date: Sun, 12 Jul 1998 09:15:18 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: on the topic of LRU lists
Message-ID: <Pine.LNX.3.96.980712091320.9888A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stephen Tweedie <sct@dcs.ed.ac.uk>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Stephen,

now that I think of multiple lists, it might be nice to
have a 2-level LRU scheme for each type of allocation:
- user pages
- shared stuff
- buffers
- page cache

Then we do a sort of round-robin allocation and memory
pressure will make sure that the amount of memory is
automatically balanced between the different uses.

(just a stupid idea)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
