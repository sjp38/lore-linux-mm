Received: (from jmm@localhost)
	by bp6.sublogic.lan (8.9.3/8.9.3) id RAA08857
	for linux-mm@kvack.org; Wed, 21 Jun 2000 17:22:45 -0400
Date: Wed, 21 Jun 2000 17:22:45 -0400
From: James Manning <jmm@computer.org>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-ID: <20000621172245.A8507@bp6.sublogic.lan>
References: <20000621204734Z131177-21003+32@kanga.kvack.org> <200006212049.NAA57630@google.engr.sgi.com> <20000621210620Z131176-21003+33@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000621210620Z131176-21003+33@kanga.kvack.org>; from ttabi@interactivesi.com on Wed, Jun 21, 2000 at 03:59:51PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[Timur Tabi]
> ** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
> Jun 2000 13:49:56 -0700 (PDT)
> > What I was warning you about is that if you shrink the array to the
> > exact size, there might be other data that comes on the same cacheline,
> > which might cause all kinds of interesting behavior (I think they call
> > this false cache sharing or some such thing).
> 
> Ok, I understand your explanation, but I have a hard time seeing how false
> cache sharing can be a bad thing.
> 
> If the cache sucks up a bunch of zeros that are never used, that's definitely
> wasted cache space.  How can that be any better than sucking up some real data
> that can be used?

The (possible) problem is that by decreasing the size of the array,
you're shifting data structures in memory and therefore shifting
their placement in caches.  Since caches exist as sets of cache lines
(an N-way associative cache having N members of each of these sets),
we may have shifted some high-traffic cachelines into the same set as
this structure.  We also may have made the situation better, but it's
hard to tell without real data on cache behavior (something I'm working
on now, but it's going slowly).

Of course, since gcc is the blessed compiler we can specify alignments
of structures to try and help the situation, and page coloring may
help the situation later down the road as well.

James
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
