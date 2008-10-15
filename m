Subject: Re: [rfc] SLOB memory ordering issue
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <200810160334.13082.nickpiggin@yahoo.com.au>
References: <200810160334.13082.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 15 Oct 2008 11:54:18 -0500
Message-Id: <1224089658.3316.218.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: torvalds@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-16 at 03:34 +1100, Nick Piggin wrote:
> I think I see a possible memory ordering problem with SLOB:
> In slab caches with constructors, the constructor is run
> before returning the object to caller, with no memory barrier
> afterwards.
> 
> Now there is nothing that indicates the _exact_ behaviour
> required here. Is it at all reasonable to expect ->ctor() to
> be visible to all CPUs and not just the allocating CPU?

Do you have a failure scenario in mind?

First, it's a categorical mistake for another CPU to be looking at the
contents of an object unless it knows that it's in an allocated state.

For another CPU to receive that knowledge (by reading a causally-valid
pointer to it in memory), a memory barrier has to occur, no?

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
