Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA07774
	for <linux-mm@kvack.org>; Fri, 12 Jun 1998 00:50:35 -0400
Date: Fri, 12 Jun 1998 06:36:53 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: update re: fork() failures in 2.1.101
In-Reply-To: <19980611173940.51846@adore.lightlink.com>
Message-ID: <Pine.LNX.3.95.980612063348.22741A-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Kimoto <kimoto@lightlink.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[Paul get's "cannot fork" errors after 60 or more hours of
 uptime. This suggests fragmentation problems.]

On Thu, 11 Jun 1998, Paul Kimoto wrote:

> > Hmm, the 'cannot fork' issue only starting after some
> > days of uptime... This suggests fragmentation. Is your
> > box very heavily loaded, or just lightly (VM-wise)?
> 
> Light, I think; I have 48MB of RAM and usually end up with 8--16MB in swap.
> In normal operation I don't have to wait much for paging except for larger
> programs (netscape, xemacs, or big compilations).

Ahh, I think I see it now. The fragmentation on your system
persists because of the swap cache. The swap cache 'caches'
swap pages and kinda makes sure they are reloaded to the
same physical address.

Stephen, Ben: should we disable the swap cache when 
fragmentation is high?

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
