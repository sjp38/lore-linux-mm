Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5344D6B0360
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 00:26:38 -0400 (EDT)
Subject: Re: [patch] slob: fix gfp flags for order-0 page allocations
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 Aug 2010 23:26:34 -0500
Message-ID: <1282623994.10679.921.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2010-08-22 at 16:16 -0700, David Rientjes wrote:
> kmalloc_node() may allocate higher order slob pages, but the __GFP_COMP
> bit is only passed to the page allocator and not represented in the
> tracepoint event.  The bit should be passed to trace_kmalloc_node() as
> well.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

>  		unsigned int order = get_order(size);
>  
> -		ret = slob_new_pages(gfp | __GFP_COMP, get_order(size), node);
> +		if (likely(order))
> +			gfp |= __GFP_COMP;

Why is it likely? I would hope that the majority of page allocations are
in fact order 0.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
