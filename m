Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA17857
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 08:09:41 -0400
Date: Fri, 19 Jun 1998 09:33:54 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: update re: fork() failures in 2.1.101
In-Reply-To: <19980618235448.18503@adore.lightlink.com>
Message-ID: <Pine.LNX.3.96.980619093210.6052C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Kimoto <kimoto@lightlink.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[CC-ed to linux-mm, and it should stay that way...]

On Thu, 18 Jun 1998, Paul Kimoto wrote:

> For completeness, here is the fragmentation report for each:
> > Jun 18 01:24:48   ( 48*4kB 7*8kB 1*16kB 1*32kB 4*64kB 1*128kB = 680kB)
> > Jun 18 18:03:53   ( 1*4kB 28*8kB 39*16kB 2*32kB 1*64kB 1*128kB = 1108kB)

Damn, this looks near-perfect for normal system load...
I really don't understand what's wrong.

> If you have other suggestions for things to try, with the reduction in
> memory (from 48 MB) the problems seem to arise in about half the time.

I wonder what kind of software / networking app you are using,
and what memory usage those programs have...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
