Date: Wed, 23 May 2007 07:11:52 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523051152.GC29045@wotan.suse.de>
References: <20070522073910.GD17051@wotan.suse.de> <20070522145345.GN11115@waste.org> <Pine.LNX.4.64.0705221216300.30149@schroedinger.engr.sgi.com> <20070523030637.GC9255@wotan.suse.de> <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com> <20070523045938.GA29045@wotan.suse.de> <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com> <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 22, 2007 at 10:06:56PM -0700, Christoph Lameter wrote:
> 
> On Wed, 23 May 2007, Nick Piggin wrote:
> 
> > Is there a patch for it? Turning on CONFIG_SLUB_DEBUG doesn't seem like
> > a good idea when trying to make a comparison.
> 
> CONFIG_SLUB_DEBUG does not turn on debugging and should be on always. This 
> is not SLAB.

I don't really know what you mean by this... CONFIG_SLUB_DEBUG adds 20K or
so to the kernel image if nothing else, which just makes a comparison
more difficult. But to me it seems like CONFIG_SLUB_DEBUG also puts extra
redzone in the object sometimes.

 
> Here is the fix:

Thanks.

> 
> 
> 
> ---
>  mm/slub.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: slub/mm/slub.c
> ===================================================================
> --- slub.orig/mm/slub.c	2007-05-21 11:21:36.000000000 -0700
> +++ slub/mm/slub.c	2007-05-21 11:21:49.000000000 -0700
> @@ -1943,7 +1943,6 @@ static int calculate_sizes(struct kmem_c
>  	 */
>  	s->inuse = size;
>  
> -#ifdef CONFIG_SLUB_DEBUG
>  	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
>  		s->ctor)) {
>  		/*
> @@ -1958,6 +1957,7 @@ static int calculate_sizes(struct kmem_c
>  		size += sizeof(void *);
>  	}
>  
> +#ifdef CONFIG_SLUB_DEBUG
>  	if (flags & SLAB_STORE_USER)
>  		/*
>  		 * Need to store information about allocs and frees after
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
