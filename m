Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2C76B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:48:49 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id g73so25581560ioe.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:48:49 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id n38si12670593ioe.157.2016.01.27.08.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 08:48:48 -0800 (PST)
Date: Wed, 27 Jan 2016 10:48:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
In-Reply-To: <56A8C788.9000004@suse.cz>
Message-ID: <alpine.DEB.2.20.1601271047480.14468@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com> <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com> <56A8C788.9000004@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 27 Jan 2016, Vlastimil Babka wrote:

> On 01/14/2016 06:24 AM, Joonsoo Kim wrote:
> > In fact, I tested another idea implementing OBJFREELIST_SLAB with
> > extendable linked array through another freed object. It can remove
> > memory waste completely but it causes more computational overhead
> > in critical lock path and it seems that overhead outweigh benefit.
> > So, this patch doesn't include it.
>
> Can you elaborate? Do we actually need an extendable linked array? Why not just
> store the pointer to the next free object into the object, NULL for the last
> one? I.e. a singly-linked list. We should never need to actually traverse it?
>
> freeing object obj:
> *obj = page->freelist;
> page->freelist = obj;
>
> allocating object:
> obj = page->freelist;
> page->freelist = *obj;
> *obj = NULL;

Well the single linked lists are a concept of another slab allocator. At
what point do we rename SLAB to SLUB2?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
