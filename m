Date: Thu, 18 Oct 2007 19:01:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Avoid atomic operation for slab_unlock
In-Reply-To: <200710191156.43049.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710181858240.4685@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com>
 <200710190949.01019.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0710181817380.4194@schroedinger.engr.sgi.com>
 <200710191156.43049.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Oct 2007, Nick Piggin wrote:

> > Yes that is what I attempted to do with the write barrier. To my knowledge
> > there are no reads that could bleed out and I wanted to avoid a full fence
> > instruction there.
> 
> Oh, OK. Bit risky ;) You might be right, but anyway I think it
> should be just as fast with the optimised bit_unlock on most
> architectures.

How expensive is the fence? An store with release semantics would be safer 
and okay for IA64.
 
> Which reminds me, it would be interesting to test the ia64
> implementation I did. For the non-atomic unlock, I'm actually
> doing an atomic operation there so that it can use the release
> barrier rather than the mf. Maybe it's faster the other way around
> though? Will be useful to test with something that isn't a trivial
> loop, so the slub case would be a good benchmark.

Lets avoid mf (too expensive) and just use a store with release semantics.

Where can I find your patchset? I looked through lkml but did not see it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
