Date: Wed, 15 Oct 2008 11:29:32 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] SLOB memory ordering issue
In-Reply-To: <200810160512.28443.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0810151127230.3288@nehalem.linux-foundation.org>
References: <200810160334.13082.nickpiggin@yahoo.com.au> <200810160445.28781.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810151058540.3288@nehalem.linux-foundation.org> <200810160512.28443.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Thu, 16 Oct 2008, Nick Piggin wrote:
> 
> When I said "I'd really hate to add a branch to the slab fastpath", it
> wasn't a tacit acknowlegement that the barrier is the only way to go,
> if it sounded that way.
> 
> I meant: I'd *really* hate to add a branch to the slab fastpath :)

Well, quite frankly, your choice of subject line and whole point of 
argument may have confused me.

You started out - and continue to - make this sound like it's a 
SLAB/SLOB/SLUB issue. It's not. 

I agree there is quite likely memory ordering issues - possibly old ones, 
but quite possibly also ones that have just happened fairly recently as 
we've done more unlocked lookups - and all I've ever disagreed with is 
how you seem to have mixed this up with the allocator.

And I still don't understand why you even _mention_ the slab fastpath. It 
seems totally immaterial.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
