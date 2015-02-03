Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 39DDC6B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 10:14:43 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id f51so2749594qge.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 07:14:42 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id f3si28950135qaq.129.2015.02.03.07.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 07:14:41 -0800 (PST)
Date: Tue, 3 Feb 2015 09:14:40 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/5] LLVMLinux: Correct size_index table before replacing
 the bootstrap kmem_cache_node.
In-Reply-To: <1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
Message-ID: <alpine.DEB.2.11.1502030913370.6059@gentwo.org>
References: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com> <1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Sanders <daniel.sanders@imgtec.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 3 Feb 2015, Daniel Sanders wrote:

> +++ b/mm/slab.c
> @@ -1440,6 +1440,7 @@ void __init kmem_cache_init(void)
>  	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache("kmalloc-node",
>  				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
>  	slab_state = PARTIAL_NODE;
> +	correct_kmalloc_cache_index_table();

Lets call this

	setup_kmalloc_cache_index_table

Please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
