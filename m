Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA14050
	for <linux-mm@kvack.org>; Sat, 13 Jun 1998 02:45:50 -0400
Date: Sat, 13 Jun 1998 08:15:33 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: TODO list, v0.01
In-Reply-To: <199806122247.XAA02295@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980613081315.3680B-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 1998, Stephen C. Tweedie wrote:
> On Thu, 11 Jun 1998 23:59:45 +0200 (MET DST), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > Other projects are yet to be added -- what ones?
> 
> Lots --- mainly sorting out performance and fragmentation issues for
> 2.2 in the short term.  More after Usenix...

The fragmentation issue will get better when I have written
the new allocator. When I keep it simple and really trivial
I might even convince Linus to merge it in a stable release.

The performance will mainly need swapin readahead. I've
found swapout to be quite fast already.
The other performance issue is with multiple scanning of
shared pages, which will be fixed for free once the PTE
chaining of you and Ben is done...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
