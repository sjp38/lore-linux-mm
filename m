Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA15028
	for <linux-mm@kvack.org>; Thu, 9 Jul 1998 17:18:59 -0400
Date: Thu, 9 Jul 1998 22:39:10 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807082211.XAA14327@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980709223502.29519A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <arcangeli@mbox.queen.it>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 1998, Stephen C. Tweedie wrote:
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > When my zone allocator is finished, it'll be a piece of
> > cake to implement lazy page reclamation.
> 
> I've already got a working implementation.  The issue of lazy
> reclamation is pretty much independent of the allocator underneath; I

We really should integrate this _now_, with the twist
that pages which could form a larger buddy should be
immediately deallocated.

This can give us a cheap way to:
- create larger memory buddies
- remove some of the pressure on the buddy allocator
  (no need to grab that last 64 kB area when 25% of
  user pages are lazy reclaim)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
