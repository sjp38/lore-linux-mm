Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id QAA00414
	for <linux-mm@kvack.org>; Fri, 23 Jun 2000 16:53:03 +0100
Subject: Re: [RFC] RSS guarantees and limits
References: <Pine.LNX.4.21.0006222022420.1137-100000@duckman.distro.conectiva>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 23 Jun 2000 16:52:59 +0100
In-Reply-To: Rik van Riel's message of "Thu, 22 Jun 2000 20:27:16 -0300 (BRST)"
Message-ID: <m2ya3wcs2s.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

[...]

> > I agree completely. It was one of the reasons I suggested that a
> > syscall like nice but giving info to the mm layer would be
> > useful. In general, small apps (xeyes,biff,gpm) don't deserve
> > any special treatment.
> 
> Why not?  In scheduling processes which use less CPU get
> a better response time. Why not do the same for memory
> use? The less memory you use, the less agressive we'll be
> in trying to take it away from you.

CPU != memory.

Quick reasons:
        (1) Sleeping process takes memory.

        (2) Take away 10% CPU from a program, it runs at about 90% of
        former speed. Take away 10% mem from a program, might only run
        at 5-10% of former speed due to having to wait for disk IO.
> 
> Of course a small app should be removed from memory when
> it's sleeping, but there's no reason to not apply some
> degree of fairness in memory allocation and memory stealing.

[...]

You say you can't see why small processes like shells etc. shouldn't
be specially treated (your first paragraph). Folding double negative,
you say there should be positive discrimination for these processes,
i.e. fairer distribution of memory (your second paragraph). 

If you think I'm not qualified to disagree, reread what Matthew Dillon
said to you while discussing VM changes in May:

    Well, I have a pretty strong opinion on trying to rationalize
    penalizing big processes simply because they are big.  It's a bad
    idea for several reasons, not the least of which being that by
    making such a rationalization you are assuming a particular system
    topology -- you are assuming, for example, that the system may
    contain a few large less-important processes and a reasonable
    number of small processes.  But if the system contains hundreds of
    small processes or if some of the large processes turn out to be
    important, the rationalization fails.

    Also if the large process in question happens to really need the
    pages (is accessing them all the time), trying to page those pages
    out gratuitously does nothing but create a massive paging load on
    the system.  Unless you have a mechanism to (such as FreeBSD has)
    to impose a 20-second forced sleep under extreme memory loads, any
    focus on large processes will simply result in thrashing (read:
    screw up the system).

[...]

> > The only general solution I can see is to give some process
> > (groups) a higher MM priority, by analogy with nice.
> 
> That you can't see anything better doesn't mean it isn't possible ;)

Indeed, I wait anxiously for someone to propose a better solution.

[...]

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
