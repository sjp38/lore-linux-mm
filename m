Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: About the free page pool
Date: Tue, 3 Sep 2002 18:46:06 +0200
References: <218D9232-BEBF-11D6-A3BE-000393829FA4@cs.amherst.edu>
In-Reply-To: <218D9232-BEBF-11D6-A3BE-000393829FA4@cs.amherst.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20020903164325Z16491-4014+1409@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

On Monday 02 September 2002 23:58, Scott Kaplan wrote:
> My goal was a different one:  I just wanted some further simplification of
> the replacement mechanism.

Simplifying the replacement mechanism has value as an aid to understanding,
or perhaps debugging.  There's also a strong case for maintaining a simple
VM design in parallel with the fancy one, as a compilation option.

Occasionally, someone will demonstrate that a far simpler design outperforms 
the fancy design de jour, causing considerable embarrassment to the incumbent 
designers.  It doesn't happen often though.  Usually, complexity is added to 
the VM for a good reason, and the fancier it gets, the better it works.  
Examples of this are division of the lru lists per zone and batching of vm 
operations.

At the risk of fueling (ahem) an analogy war, consider the classic 
carburetor.  As a means of mixing fuel and air for combustion, it's about as 
simple as you can get, but you can tweak the design as much as you like and 
it will never perform as well as a computer-controlled fuel injection system.

Even with all the recent optimizations lathered on, we are still working with 
a very simple underlying design, more like a carburetor than a flue injection 
system.  We mainly cross our fingers and hope that the system will magically 
solve its own problems.  For example, we hope that by making threads do their 
own vm scanning they will throttle and balance their memory consumption 
properly versus other threads.  This strategy has never worked reliably 
across a broad range of loads, though after a few years of tweaking, many of 
its typical faux pas have been identified and suppressed.

Such bandaid solutions do work for a time.  The problem is, the bandaids tend 
not to scale very well, either up or down.  So each new kernel generation 
requires a new set of bandaids, and usually a new team of medics to apply 
them.  After a while, the bandaids alone add up to more lines of code than 
the underlying VM mechanism, and it's time for a paradigm shift.  We're 
nearly at that point now.

In other words, after 2.6, carburetors will be out and computer-controlled 
fuel-injection will be in.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
