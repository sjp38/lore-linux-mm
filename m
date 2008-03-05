Date: Wed, 5 Mar 2008 14:31:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
Message-ID: <20080305143117.GB7592@csn.ul.ie>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org> <47CD4AB3.3080409@linux.vnet.ibm.com> <20080304103636.3e7b8fdd.akpm@linux-foundation.org> <47CDA081.7070503@cs.helsinki.fi> <20080304193532.GC9051@csn.ul.ie> <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com> <Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0803041205370.18277@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803041205370.18277@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linuxppc-dev@ozlabs.org, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (04/03/08 12:07), Christoph Lameter didst pronounce:
> I think this is the correct fix.
> 
> The NUMA fallback logic should be passing local_flags to kmem_get_pages() 
> and not simply the flags.
> 
> Maybe a stable candidate since we are now simply 
> passing on flags to the page allocator on the fallback path.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks Christoph.

> 
> ---
>  mm/slab.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.25-rc3-mm1/mm/slab.c
> ===================================================================
> --- linux-2.6.25-rc3-mm1.orig/mm/slab.c	2008-03-04 12:01:07.430911920 -0800
> +++ linux-2.6.25-rc3-mm1/mm/slab.c	2008-03-04 12:04:54.449857145 -0800
> @@ -3277,7 +3277,7 @@ retry:
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_enable();
>  		kmem_flagcheck(cache, flags);
> -		obj = kmem_getpages(cache, flags, -1);
> +		obj = kmem_getpages(cache, local_flags, -1);
>  		if (local_flags & __GFP_WAIT)
>  			local_irq_disable();
>  		if (obj) {
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
