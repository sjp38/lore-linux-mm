Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F3F176B01FF
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:14:28 -0400 (EDT)
Date: Wed, 25 Aug 2010 13:13:44 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for August 25 (mm/slub)
Message-Id: <20100825131344.a2c26b31.randy.dunlap@oracle.com>
In-Reply-To: <alpine.DEB.2.00.1008251447410.22117@router.home>
References: <20100825132057.c8416bef.sfr@canb.auug.org.au>
	<20100825094559.bc652afe.randy.dunlap@oracle.com>
	<alpine.DEB.2.00.1008251409260.22117@router.home>
	<20100825122134.2ac33360.randy.dunlap@oracle.com>
	<alpine.DEB.2.00.1008251447410.22117@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 14:51:14 -0500 (CDT) Christoph Lameter wrote:

> On Wed, 25 Aug 2010, Randy Dunlap wrote:
> 
> > Certainly.  config file is attached.
> 
> Ah. Memory hotplug....
> 
> 
> 
> Subject: Slub: Fix up missing kmalloc_cache -> kmem_cache_node case for memoryhotplug
> 
> Memory hotplug allocates and frees per node structures. Use the correct name.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
>  mm/slub.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-08-25 14:48:23.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-08-25 14:49:03.000000000 -0500
> @@ -2909,7 +2909,7 @@ static void slab_mem_offline_callback(vo
>  			BUG_ON(slabs_node(s, offline_node));
> 
>  			s->node[offline_node] = NULL;
> -			kmem_cache_free(kmalloc_caches, n);
> +			kmem_cache_free(kmem_cache_node, n);
>  		}
>  	}
>  	up_read(&slub_lock);
> @@ -2942,7 +2942,7 @@ static int slab_mem_going_online_callbac
>  		 *      since memory is not yet available from the node that
>  		 *      is brought up.
>  		 */
> -		n = kmem_cache_alloc(kmalloc_caches, GFP_KERNEL);
> +		n = kmem_cache_alloc(kmem_cache_node, GFP_KERNEL);
>  		if (!n) {
>  			ret = -ENOMEM;
>  			goto out;


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
