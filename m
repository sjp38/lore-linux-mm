Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA31351
	for <linux-mm@kvack.org>; Wed, 25 Mar 1998 18:40:57 -0500
Date: Wed, 25 Mar 1998 15:40:29 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: free_memory_available() bug in pre-91-1
In-Reply-To: <Pine.LNX.3.91.980324235724.469A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980325153614.17979T-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "H.H.vanRiel" <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Wed, 25 Mar 1998, H.H.vanRiel wrote:
> 
> I've just found a bug in free_memory_available() as
> implemented in pre-91-1...

Ugh, yes. How about pre-91-2, which I just put out? It has more of the
code the way I _think_ it should be, and it should try a lot harder to not
hog the CPU with kswapd. 

On a 512MB machine, the "tries" variable easily defaulted to try to page
out 8192 pages at a time, which was what we in the business call "Bad For
Interactive Use" (TM). The new one tries to throw out much fewer pages,
and is happier about being called more often - so kswapd really should be
more of a "background" thing rather than quite easily becoming
foregrounded.

All of this is completely untested in real life, but has gone through the
very strict "Looks Ok To Me" bs-filter. Thus it is obviously perfect and
can have no bugs. As such everybody should immediately upgrade and be
happy forever after. 

		Linus
