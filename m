Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF70C6B000C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:32:03 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id g2so10732ioj.18
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:32:03 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id 98si10830480ioq.332.2018.03.06.10.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 10:32:02 -0800 (PST)
Date: Tue, 6 Mar 2018 12:32:01 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 04/25] slab: make create_kmalloc_cache() work with 32-bit
 sizes
In-Reply-To: <20180305200730.15812-4-adobriyan@gmail.com>
Message-ID: <alpine.DEB.2.20.1803061226250.29393@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-4-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Mon, 5 Mar 2018, Alexey Dobriyan wrote:

> KMALLOC_MAX_CACHE_SIZE is 32-bit so is the largest kmalloc cache size.

Ok SLABs maximum allocation size is limited to 32M (see
include/linux/slab.h:

#define KMALLOC_SHIFT_HIGH      ((MAX_ORDER + PAGE_SHIFT - 1) <= 25 ? \
                                (MAX_ORDER + PAGE_SHIFT - 1) : 25)

And SLUB/SLOB pass all larger requests to the page allocator anyways.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
