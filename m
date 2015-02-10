Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id C741B6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 16:51:36 -0500 (EST)
Received: by iecrd18 with SMTP id rd18so16201309iec.5
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 13:51:36 -0800 (PST)
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com. [209.85.223.182])
        by mx.google.com with ESMTPS id n7si167758igj.44.2015.02.10.13.51.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 13:51:36 -0800 (PST)
Received: by iery20 with SMTP id y20so19846764ier.9
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 13:51:36 -0800 (PST)
Date: Tue, 10 Feb 2015 13:51:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slab_common: Use kmem_cache_free
In-Reply-To: <20150209052835.GA3559@vaishali-Ideapad-Z570>
Message-ID: <alpine.DEB.2.10.1502101351210.18749@chino.kir.corp.google.com>
References: <20150209052835.GA3559@vaishali-Ideapad-Z570>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaishali Thakkar <vthakkar1994@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 9 Feb 2015, Vaishali Thakkar wrote:

> Here, free memory is allocated using kmem_cache_zalloc.
> So, use kmem_cache_free instead of kfree.
> 
> This is done using Coccinelle and semantic patch used
> is as follows:
> 
> @@
> expression x,E,c;
> @@
> 
>  x = \(kmem_cache_alloc\|kmem_cache_zalloc\|kmem_cache_alloc_node\)(c,...)
>  ... when != x = E
>      when != &x
> ?-kfree(x)
> +kmem_cache_free(c,x)
> 
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
