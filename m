Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA00173
	for <linux-mm@kvack.org>; Wed, 13 Nov 2002 17:36:26 -0800 (PST)
Message-ID: <3DD2FE18.72968FEE@digeo.com>
Date: Wed, 13 Nov 2002 17:36:24 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] uClinux slab limits
References: <20021114020934.A17934@lst.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: manfred@colorfullife.com, gerg@snapgear.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> 
> +#ifndef CONFIG_MMU
> +       CN("size-262144"),
> +       CN("size-524288"),
> +       CN("size-1048576"),
> +#ifdef CONFIG_LARGE_ALLOCS
> +       CN("size-2097152"),
> +       CN("size-4194304"),
> +       CN("size-8388608"),
> +       CN("size-16777216"),
> +       CN("size-33554432"),
> +#endif /* CONFIG_LARGE_ALLOCS */
> +#endif /* CONFIG_MMU */
>  };
>  #undef CN
> 

You could just do:

#if CONFIG_LARGEST_SLAB_ORDER >= 20
	CN("size-1048576"),
#endif
#if CONFIG_LARGEST_SLAB_ORDER >= 21
	CN("size-2097152"),
#endif
#if CONFIG_LARGEST_SLAB_ORDER >= 22
	CN("size-4194304"),
#endif

etcetera.


But I think it'd be better to just remove those statically initialised
tables and put a good old for-loop in kmem_cache_init().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
