Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA03569
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 14:53:49 -0500
Date: Thu, 26 Mar 1998 19:54:22 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: [PATCH] swapout speedup 2.1.91-pre2
In-Reply-To: <Pine.LNX.3.95.980326093755.32429H-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980326195316.702B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 1998, Linus Torvalds wrote:

> > here's the speedup patch I promised earlier.
> > It:
> > - increases tries when we're tight on memory
> > - clusters swapouts from user programs (to save disk movement)
> > - wraps the above in a nice inline
> > 
> > NOTE: this patch is untested, but otherwise completely trivial :)
> 
> Ok, this looks more like the kind of algorithms I wanted. I alread knew
> that the hardcoded "50" was wrong, your heuristic looks sensible (with the
> modification you already sent to make it slightly less aggressive). 
> 
> Anyway, I'm fairly happy with this kind of setup, I'll make a real 2.1.91
> soonish,

Please, don't make it yet, we need some page cache limitation
algorithm too because my machine (and I suspect other midrange
PCees too) just thrashed itself to death because of this...

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
