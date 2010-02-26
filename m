Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB3B6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 19:34:20 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o1Q0YHdJ024278
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 00:34:17 GMT
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by spaceape14.eur.corp.google.com with ESMTP id o1Q0YAN7002746
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:34:16 -0800
Received: by pxi1 with SMTP id 1so299291pxi.16
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:34:10 -0800 (PST)
Date: Thu, 25 Feb 2010 16:34:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] slab: fix kmem_cache definition
In-Reply-To: <1267078900-4626-1-git-send-email-dmonakhov@openvz.org>
Message-ID: <alpine.DEB.2.00.1002251632520.1194@chino.kir.corp.google.com>
References: <1267078900-4626-1-git-send-email-dmonakhov@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dmitry Monakhov <dmonakhov@openvz.org>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, akinobu.mita@gmail.com, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 25 Feb 2010, Dmitry Monakhov wrote:

> SLAB_XXX flags in slab.h has defined as unsigned long.
> This definition is in sync with kmem_cache->flag in slub and slob
> But slab defines kmem_cache->flag as "unsigned int".
> 
> Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>

Acked-by: David Rientjes <rientjes@google.com>

Added Pekka since this needs to go through him for slab-2.6.git.

> ---
>  include/linux/slab_def.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index ca6b2b3..49bb71f 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -34,7 +34,7 @@ struct kmem_cache {
>  	u32 reciprocal_buffer_size;
>  /* 3) touched by every alloc & free from the backend */
>  
> -	unsigned int flags;		/* constant flags */
> +	unsigned long flags;		/* constant flags */
>  	unsigned int num;		/* # of objs per slab */
>  
>  /* 4) cache_grow/shrink */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
