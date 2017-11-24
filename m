Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B50B26B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 20:06:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s75so20164113pgs.12
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:06:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s68si16892049pgb.168.2017.11.23.17.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 17:06:41 -0800 (PST)
Date: Thu, 23 Nov 2017 17:06:38 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 03/23] slab: create_kmalloc_cache() works with 32-bit
 sizes
Message-ID: <20171124010638.GA3722@bombadil.infradead.org>
References: <20171123221628.8313-1-adobriyan@gmail.com>
 <20171123221628.8313-3-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123221628.8313-3-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On Fri, Nov 24, 2017 at 01:16:08AM +0300, Alexey Dobriyan wrote:
> -struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
> +struct kmem_cache *__init create_kmalloc_cache(const char *name, unsigned int size,
>  				slab_flags_t flags)

Could you reflow this one?  Surprised checkpatch didn't whinge.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
