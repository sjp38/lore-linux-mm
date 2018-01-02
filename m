Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79C286B02B4
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 09:56:18 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id a2so20996237ioc.12
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 06:56:18 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id n138si23688650itb.16.2018.01.02.06.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 06:56:17 -0800 (PST)
Date: Tue, 2 Jan 2018 08:56:15 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 3/8] slub: Add isolate() and migrate() methods
In-Reply-To: <20180101212039.GA13116@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801020855560.14141@nuc-kabylake>
References: <20171227220636.361857279@linux.com> <20171227220652.402842142@linux.com> <20171230064246.GC27959@bombadil.infradead.org> <20180101212039.GA13116@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Mon, 1 Jan 2018, Matthew Wilcox wrote:

> I thought of a cute additional slab operation we could define, print().
> We could do something like this ...
>
>         struct page *page = virt_to_head_page(ptr);
>         if (!PageSlab(page))
>                 return false;
>         slab = page->slab_cache;
>         if (!(slab->flags & SLAB_FLAGS_OPS) || !slab->ops->print)
>                 return false;
>         slab->ops->print(ptr);
>         return true;
>
> and get nice debugging output like we have for VM_BUG_ON_PAGE, only
> for any type that's implemented a slab operations vec.  Of course, this
> won't replace VM_BUG_ON_PAGE because struct pages aren't slab-allocated
> (but could we pretend they are?)

Cute...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
