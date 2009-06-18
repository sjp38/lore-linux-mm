Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0816B004D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 16:24:44 -0400 (EDT)
Date: Thu, 18 Jun 2009 13:24:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bootmem.c: Avoid c90 declaration warning
Message-Id: <20090618132410.0b55cd90.akpm@linux-foundation.org>
In-Reply-To: <1245355633.29927.16.camel@Joe-Laptop.home>
References: <1245355633.29927.16.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009 13:07:13 -0700
Joe Perches <joe@perches.com> wrote:

> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 282df0a..09d9c98 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -536,11 +536,13 @@ static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
>  		return kzalloc(size, GFP_NOWAIT);
>  
>  #ifdef CONFIG_HAVE_ARCH_BOOTMEM
> +	{
>  	bootmem_data_t *p_bdata;
>  
>  	p_bdata = bootmem_arch_preferred_node(bdata, size, align, goal, limit);
>  	if (p_bdata)
>  		return alloc_bootmem_core(p_bdata, size, align, goal, limit);
> +	}
>  #endif
>  	return NULL;
>  }

Well yes.

We'll be needing some tabs there.

Unrelatedly, I'm struggling a bit with bootmem_arch_preferred_node(). 
It's only defined if CONFIG_X86_32=y && CONFIG_NEED_MULTIPLE_NODES=y,
but it gets called if CONFIG_HAVE_ARCH_BOOTMEM=y.

Is this correct, logical and as simple as we can make it??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
