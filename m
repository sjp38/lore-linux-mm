Date: Wed, 16 May 2001 10:26:42 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105161726.f4GHQg472438@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105131417550.5468-100000@imladris.rielhome.conectiva> <3B00CECF.9A3DEEFA@mindspring.com> <200105151724.f4FHOYt54576@earth.backplane.com> <3B0238EB.DF435099@mindspring.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Terry Lambert <tlambert2@mindspring.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:I think a lot of the "administrative limits" are stupid;
:in particular, I think it's really dumb to have 70% free
:resources, and yet enforce administrative limits as if all
:...

    The 'memoryuse' resource limit is not enforced unless
    the system is under memory pressure.

:...
:>     And without being able to make the prediction
:>     accurately you simply cannot determine how much data
:>     you should try to cache before you begin recycling it.
:
:I should think that would be obvious: nearly everything
:you can, based on locality and number of concurrent
:references.  It's only when you attempt prefetch that it
:actually becomes complicated; deciding to throw away a
:clean page later instead of _now_ costs you practically
:nothing.
:...

    Prefetching has nothing to do with what we've been
    talking about.  We don't have a problem caching prefetched
    pages that aren't used.  The problem we have is determining 
    when to throw away data once it has been used by a program.

:...
:>     So the jist of the matter is that FreeBSD (1) already
:>     has process-wide working set limitations which are
:>     activated when the system is under load,
:
:They are largely useless, since they are also active even
:when the system is not under load, so they act as preemptive
:...

    This is not true.  Who told you this?  This is absolutely
    not true.

:drags on performance.  They are also (as was pointed out in
:an earlier thread) _not_ applied to mmap() and other regions,
:so they are easily subverted.
:...
:
:-- Terry
:

    This is not true.  The 'memoryuse' limit applies to all
    in-core pages associated with the process, whether mmap()'d
    or not.

					-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
