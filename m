Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA13914
	for <linux-mm@kvack.org>; Wed, 9 Dec 1998 20:21:44 -0500
Date: Thu, 10 Dec 1998 02:10:34 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <Pine.LNX.3.96.981210001237.792A-100000@laser.bogus>
Message-ID: <Pine.LNX.4.03.9812100208190.30852-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 1998, Andrea Arcangeli wrote:
> On Wed, 9 Dec 1998, Rik van Riel wrote:
> 
> >This is because 'swapped' data is added to the cache. It also
> >is because without it kswapd would not free memory in swap_out().
> >Then, because it didn't free memory, it would continue to swap
> >out more and more and still more with no effect (remember the
> >removal of page aging?).
> 
> Nono, I reversed the vmscan changes on my tree. On my tree when
> swap_out returns 1 it has really freed a page ;).

swap_out() _never_ frees a page any more. It pushes the
pages out to swap and dereferences them so we can free
them with shrink_mmap(). This provides free page aging
and several more benefits.

You can play with the algorithms as much as you want,
however -- I'll be interested to hear about the results...

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
