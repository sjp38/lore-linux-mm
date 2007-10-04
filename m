Subject: Re: [13/18] x86_64: Allow fallback for the stack
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <200710041425.43343.ak@suse.de>
References: <20071004035935.042951211@sgi.com>
	 <200710041356.51750.ak@suse.de> <1191499692.22357.4.camel@twins>
	 <200710041425.43343.ak@suse.de>
Content-Type: text/plain
Date: Thu, 04 Oct 2007 14:30:09 +0200
Message-Id: <1191501009.22357.7.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-04 at 14:25 +0200, Andi Kleen wrote:
> > The order-1 allocation failures where GFP_ATOMIC, because SLUB uses !0
> > order for everything.
> 
> slub is wrong then. Can it be fixed?

I think mainline slub doesn't do this, just -mm.

See DEFAULT_MAX_ORDER in mm/slub.c

> > Kernel stack allocation is GFP_KERNEL I presume. 
> 
> Of course.
> 
> > Also, I use 4k stacks on all my machines.
> 
> You don't have any x86-64 machines?

Ah, my bad, yes I do, but I (wrongly) thought they had that option too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
