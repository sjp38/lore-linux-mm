Message-ID: <19980304093300.08111@Elf.mj.gts.cz>
Date: Wed, 4 Mar 1998 09:33:00 +0100
From: Pavel Machek <pavel@elf.ucw.cz>
Subject: Re: [PATCH] kswapd fix & logic improvement
References: <Pine.LNX.3.91.980303181105.414D-100000@mirkwood.dummy.home> <Pine.LNX.3.95.980303141259.12379A-100000@as200.spellcast.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.980303141259.12379A-100000@as200.spellcast.com>; from Benjamin C.R. LaHaise on Tue, Mar 03, 1998 at 02:17:33PM -0500
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, "Michael L. Galbraith" <mikeg@weiden.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi!

> ...
> > > Turned out the kswapd messages weren't related to the thrashing.
> > > I would have seen it if I hadn't jumped straight into X.
> > 
> > Ahh, yes. X allocates a _lot_ of memory at once, and then
> > the damn thing _uses_ it at once... This is guaranteed to
> > make kswapd a bit nervous, both with or without my patch.
> 
> Not only that, but the network activity X induces puts additional stress
> on an already low-memory system by allocating lots of unswappable memory.
> When might we see Pavel's patches to the networking stack meant to get
> swapping over TCP working, but I think they'll really help stability on 
> systems with low-memory and busy networks, get integrated?

Sorry? My patches are usable only if you are trying to swap over
network. They will not help on low-memory systems, unless that systems
also lack hard-drives. It is usually much better to swap onto local
drive than over network.
								Pavel
-- 
I'm really pavel@atrey.karlin.mff.cuni.cz. 	   Pavel
Look at http://atrey.karlin.mff.cuni.cz/~pavel/ ;-).
