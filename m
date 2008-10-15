Subject: Re: [rfc] SLOB memory ordering issue
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <200810160512.28443.nickpiggin@yahoo.com.au>
References: <200810160334.13082.nickpiggin@yahoo.com.au>
	 <200810160445.28781.nickpiggin@yahoo.com.au>
	 <alpine.LFD.2.00.0810151058540.3288@nehalem.linux-foundation.org>
	 <200810160512.28443.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 15 Oct 2008 13:19:13 -0500
Message-Id: <1224094753.3316.266.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-16 at 05:12 +1100, Nick Piggin wrote:
> On Thursday 16 October 2008 05:03, Linus Torvalds wrote:
> > On Thu, 16 Oct 2008, Nick Piggin wrote:
> > > What do you mean by the allocation is stable?
> >
> > "all writes done to it before it's exposed".
> >
> > > 2. I think it could be easy to assume that the allocated object that was
> > > initialised with a ctor for us already will have its initializing stores
> > > ordered when we get it from slab.
> >
> > You make tons of assumptions.
> >
> > You assume that
> >  (a) unlocked accesses are the normal case and should be something the
> >      allocator should prioritize/care about.
> >  (b) that if you have a ctor, it's the only thing the allocator will do.
> 
> Yes, as I said, I do not want to add a branch and/or barrier to the
> allocator for this. I just want to flag the issue and discuss whether
> there is anything that can be done about it.

Well the alternative is to have someone really smart investigate all the
lockless users of ctors and add appropriate barriers. I suspect that's a
fairly small set and that you're already familiar with most of them.

But yes, I think you may be on to a real problem. It might also be worth
devoting a few neurons to thinking about zeroed allocations.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
