Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA02946
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 12:39:54 -0500
Date: Thu, 26 Mar 1998 09:39:11 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] swapout speedup 2.1.91-pre2
In-Reply-To: <Pine.LNX.3.91.980326121934.19975A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980326093755.32429H-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Thu, 26 Mar 1998, Rik van Riel wrote:
> 
> here's the speedup patch I promised earlier.
> It:
> - increases tries when we're tight on memory
> - clusters swapouts from user programs (to save disk movement)
> - wraps the above in a nice inline
> 
> NOTE: this patch is untested, but otherwise completely trivial :)

Ok, this looks more like the kind of algorithms I wanted. I alread knew
that the hardcoded "50" was wrong, your heuristic looks sensible (with the
modification you already sent to make it slightly less aggressive). 

Anyway, I'm fairly happy with this kind of setup, I'll make a real 2.1.91
soonish,

		Linus
