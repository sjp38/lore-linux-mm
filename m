Date: Thu, 2 Aug 2007 17:52:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] balance-on-fork NUMA placement
In-Reply-To: <20070803002639.GC14775@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0708021748110.13312@schroedinger.engr.sgi.com>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de>
 <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com>
 <20070802034201.GA32631@wotan.suse.de> <Pine.LNX.4.64.0708021254160.8527@schroedinger.engr.sgi.com>
 <20070803002639.GC14775@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2007, Nick Piggin wrote:

> > Add a (slow) kmalloc_policy? Strict Object round robin for interleave 
> > right? It probably needs its own RR counter otherwise it disturbs the per 
> > task page RR.
> 
> I guess interleave could be nice for other things, but for this, I
> just want MPOL_BIND to work. The problem is that the pagetable copying
> etc codepaths cover a lot of code and some of it (eg pagetable allocation)
> is used for other paths as well.. so I was just hoping to do something
> less intrusive for now if possible.

Ok. So MPOL_BIND on a single node. We would have to save the current 
memory policy on the stack and then restore it later. Then you would need 
a special call anyways.

Or is there some way to execute the code on the target cpu? That may be 
the easiest solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
