Date: Tue, 3 Mar 1998 14:17:33 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [PATCH] kswapd fix & logic improvement
In-Reply-To: <Pine.LNX.3.91.980303181105.414D-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980303141259.12379A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Michael L. Galbraith" <mikeg@weiden.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Mar 1998, Rik van Riel wrote:
...
> > Turned out the kswapd messages weren't related to the thrashing.
> > I would have seen it if I hadn't jumped straight into X.
> 
> Ahh, yes. X allocates a _lot_ of memory at once, and then
> the damn thing _uses_ it at once... This is guaranteed to
> make kswapd a bit nervous, both with or without my patch.

Not only that, but the network activity X induces puts additional stress
on an already low-memory system by allocating lots of unswappable memory.
When might we see Pavel's patches to the networking stack meant to get
swapping over TCP working, but I think they'll really help stability on 
systems with low-memory and busy networks, get integrated?

		-ben
