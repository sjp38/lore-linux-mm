Received: by wr-out-0506.google.com with SMTP id i11so16324wra
        for <linux-mm@kvack.org>; Fri, 04 Aug 2006 09:03:16 -0700 (PDT)
Message-ID: <84144f020608040903sdc164edreed3c6c25b7e8c8d@mail.gmail.com>
Date: Fri, 4 Aug 2006 19:03:14 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 3/3] slab: account leaks to caller version of kmalloc_node
In-Reply-To: <20060804151554.GC29422@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060804151554.GC29422@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@osdl.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/4/06, Christoph Hellwig <hch@lst.de> wrote:
> +#ifndef CONFIG_DEBUG_SLAB
> +void *__kmalloc_node(size_t size, gfp_t flags, int node)
> +{
> +       return __do_kmalloc_node(size, flags, node,
> +                       __builtin_return_address(0));
> +}
> +EXPORT_SYMBOL(__kmalloc_node);
> +
> +void *__kmalloc_node_track_caller(size_t size, gfp_t flags,
> +               int node, void *caller)
> +{
> +       return __do_kmalloc_node(size, flags, node, caller);
> +}
> +EXPORT_SYMBOL(__kmalloc_node_track_caller);
> +#else
> +void *__kmalloc_node(size_t size, gfp_t flags, int node)
> +{
> +       return __do_kmalloc_node(size, flags, node, NULL);
> +}
> +EXPORT_SYMBOL(__kmalloc_node);
>  #endif

You are passing NULL when CONFIG_DEBUG_SLAB is enabled but you want it
the other way around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
