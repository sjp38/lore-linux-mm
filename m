Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 59BC66B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 00:17:31 -0400 (EDT)
Date: Wed, 5 Aug 2009 21:17:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slqb: add declaration for kmem_cache_init_late()
Message-Id: <20090805211727.cd4ccedd.akpm@linux-foundation.org>
In-Reply-To: <20090806022704.GA17337@localhost>
References: <20090806022704.GA17337@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Aug 2009 10:27:04 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:

> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/slqb_def.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- linux-mm.orig/include/linux/slqb_def.h	2009-07-20 20:10:20.000000000 +0800
> +++ linux-mm/include/linux/slqb_def.h	2009-08-06 10:17:05.000000000 +0800
> @@ -298,4 +298,6 @@ static __always_inline void *kmalloc_nod
>  }
>  #endif
>  
> +void __init kmem_cache_init_late(void);
> +
>  #endif /* _LINUX_SLQB_DEF_H */

spose so.

As all sl[a-zA-Z_]b.c must implement this, why not put the declaration
into slab.h?

That would require uninlining the slob one, but it's tiny and __init.

That's one for Pekka to worry about ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
