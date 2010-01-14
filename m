Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E2CB46B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 15:59:02 -0500 (EST)
Date: Thu, 14 Jan 2010 14:58:52 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
In-Reply-To: <20100114203221.GI4545@ldl.fc.hp.com>
Message-ID: <alpine.DEB.2.00.1001141457250.19915@router.home>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com> <20100114203221.GI4545@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jan 2010, Alex Chiang wrote:

> coffee0:/usr/src/linux-2.6 # addr2line 0xa0000001001add60 -e vmlinux
> /usr/src/linux-2.6/include/linux/mm.h:543
>
>  538 #ifdef NODE_NOT_IN_PAGE_FLAGS
>  539 extern int page_to_nid(struct page *page);
>  540 #else
>  541 static inline int page_to_nid(struct page *page)
>  542 {
>  543         return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
>  544 }
>  545 #endif

That may mean that early_kmem_node_alloc gets a screwy page number from
the page allocator? ????

Can you print the address of page returned from new_slab() in
early_kmem_cache_node_alloc()?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
