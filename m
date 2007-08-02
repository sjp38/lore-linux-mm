Date: Thu, 2 Aug 2007 12:58:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] balance-on-fork NUMA placement
In-Reply-To: <20070802034201.GA32631@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0708021254160.8527@schroedinger.engr.sgi.com>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de>
 <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com>
 <20070802034201.GA32631@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Nick Piggin wrote:

> > It does in the sense that slabs are allocated following policies. If you 
> > want to place individual objects then you need to use kmalloc_node().
> 
> Is there no way to place objects via policy? At least kernel stack and page
> tables on x86-64 should be covered by page allocator policy, so the patch
> will still be useful.

Implementing policies on an object level introduces significant allocator 
overhead. Tried to do it in SLAB which created a mess.

Add a (slow) kmalloc_policy? Strict Object round robin for interleave 
right? It probably needs its own RR counter otherwise it disturbs the per 
task page RR.

For interleave kmalloc() does allocate the slabs round robin not the 
objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
