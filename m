Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 393BF6B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 14:09:32 -0400 (EDT)
Date: Fri, 21 May 2010 13:06:22 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: move kmem_cache_node into it's own cacheline
In-Reply-To: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
Message-ID: <alpine.DEB.2.00.1005211305340.14851@router.home>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010, Alexander Duyck wrote:

> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 0249d41..e6217bb 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -52,7 +52,7 @@ struct kmem_cache_node {
>  	atomic_long_t total_objects;
>  	struct list_head full;
>  #endif
> -};
> +} ____cacheline_internodealigned_in_smp;

What does this do? Leftovers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
