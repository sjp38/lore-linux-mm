Message-ID: <3911E8CB.AD90A518@sgi.com>
Date: Thu, 04 May 2000 14:16:59 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005041202310.811-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Thu, 4 May 2000, Rik van Riel wrote:
> 
> > On Thu, 4 May 2000, Linus Torvalds wrote:
> >
> > > Note that changing how hard try_to_free_pages() tries to free a page is
> > > exactly part of what Rik has been doing, so this is something that has
> > > changed recently. It's not trivial to get right, for a very simple reason:
> > > we need to balance the "hardness" between the VM area scanning and the RLU
> > > list scanning.
> >
> > With the current scheme, it's pretty much impossible to get it
> > right.
> 
> Not really. That is what the "priority levels" are really there for: for

	[ ... discussion about shrink_mmap() ... ]

> This, I think, is where the new swap_out() falls down flat on its face. It
	
	[ ... discussion about swap_out() ... ]

I looked over the latest (7-4) implementation of swap_out,
shrink_mmap & try_to_free_pages, etc.

One clarification: In the case I reported only
dbench was running, presumably doing a lot of read/write. So, why
isn't shrink_mmap able to find freeable pages? Is it because
the shrink_mmap() is too conservative about implementing LRU?
I mean, it doesn't make sense to swap pages just to keep others
in cache ... if the demand is too high, start shooting down
pages regardless.

Or, is shrink_mmap bailing not because of referenced bit,
but because bdflush is too slow, for example? That is,
are the pages having active I/O so can't be freed?

Do you guys think a profile using gcc-style mcount
would be useful?


-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
