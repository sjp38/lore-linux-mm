Date: Fri, 6 Mar 1998 04:06:22 -0500 (U)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [PATCH] kswapd fix & logic improvement
In-Reply-To: <19980304093300.08111@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.95.980306035709.11210A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@elf.ucw.cz>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, "Michael L. Galbraith" <mikeg@weiden.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hello!

On Wed, 4 Mar 1998, Pavel Machek wrote:
...
> > Not only that, but the network activity X induces puts additional stress
> > on an already low-memory system by allocating lots of unswappable memory.
> > When might we see Pavel's patches to the networking stack meant to get
> > swapping over TCP working, but I think they'll really help stability on 
> > systems with low-memory and busy networks, get integrated?
> 
> Sorry? My patches are usable only if you are trying to swap over
> network. They will not help on low-memory systems, unless that systems
> also lack hard-drives. It is usually much better to swap onto local
> drive than over network.

If they're setup the way I think they are, you're mistaken. ;-)  I'm
thinking of the pathelogical case where the system is thrown into a state
where atomic memory consumption is occurring faster than the system can
free up memory.  This could occur on a system with, say 100Mbps ethernet
and a low-end IDE drive (~5-7MBps peak) if we're using TCP with large
windows and have a *large* number of sockets open and receiving data. 
Incoming packets could consume up to 10MB of GFP_ATOMIC memory per second
- ouch!  With your patch, once we hit a danger zone, the system starts
dropping network packets, right?  That way there will still be enough
memory for allocating buffer heads and such to swap out as nescessary... 

		-ben
