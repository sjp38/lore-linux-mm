Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA07994
	for <linux-mm@kvack.org>; Fri, 3 Jul 1998 12:37:05 -0400
Date: Fri, 3 Jul 1998 17:21:51 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Thread implementations... 
In-Reply-To: <199807010850.JAA00764@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980703171908.20629B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jul 1998, Stephen C. Tweedie wrote:

> sequential clusters, but if we have things like Ingo's random swap
> stats-based prediction logic, then we can use exactly the same extent
> concept there too.

Hmm, it appears this was the legendary swap readahead code I
was looking for a while ago :)

But, ehhh, just what _is_ this random swap stats-based prediction
algorithm, and how far from implementation is it?
(and if it isn't implemented yet, what should I do to make
it implemented; swapin readahead is very wanted on my
memory-starved box...)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
