Date: Tue, 24 Jul 2007 17:53:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Slab API: Remove useless ctor parameter and reorder parameters
Message-Id: <20070724175332.41ade708.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707241705380.9633@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
	<20070724165914.a5945763.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707241705380.9633@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007 17:35:53 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 24 Jul 2007, Andrew Morton wrote:
> 
> > arch/i386/mm/pgtable.c:197: error: conflicting types for 'pmd_ctor'
> > include/asm/pgtable.h:43: error: previous declaration of 'pmd_ctor' was here
> 
> Ahh. External declaration of pmd_ctor missed in .h. Patch follows. 

<regards it in terror>

> > Now is the 100% worst time to merge this sort of thing btw: I get to carry
> > it for two months while the world churns.  Around the -rc7 timeframe would 
> > be better.
> 
> We just got rid of the destructor parameter of kmem_cache_create.

Yeah, but that got merged into mainline.  It's too late to merge this one.

> It would 
> be consistent to  also get rid of the useless flag in the ctor at the 
> same time.

Honest, it's easier for everyone if we shelve this until late -rc's.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
