Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e3.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id OAA10052
	for <linux-mm@kvack.org>; Fri, 23 Jun 2000 14:07:04 -0400
From: frankeh@us.ibm.com
Received: from D51MTA03.pok.ibm.com (d51mta03.pok.ibm.com [9.117.200.31])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.9) with SMTP id OAA182726
	for <linux-mm@kvack.org>; Fri, 23 Jun 2000 14:08:55 -0400
Message-ID: <85256907.0063AC1B.00@D51MTA03.pok.ibm.com>
Date: Fri, 23 Jun 2000 14:07:50 -0400
Subject: Re: [RFC] RSS guarantees and limits
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John, ...

I thought Rik actually takes care of that.  He doesn't necessarily penalize
a process because it is big.
He penalizes the process if its working set size is substantially smaller
than then its memory footprint.
His measure for that is the refault rate. If he takes away pages that are
shortly thereafter being faulted back in, than as he stated, he is to
agressive. Since this refaulting is cheap when the page is still in the
cache, the overhead should be reasonable small.

-- Hubertus



"John Fremlin" <vii@penguinpowered.com>@kvack.org on 06/23/2000 11:52:59 AM

Sent by:  owner-linux-mm@kvack.org


To:   <linux-mm@kvack.org>
cc:
Subject:  Re: [RFC] RSS guarantees and limits



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



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
