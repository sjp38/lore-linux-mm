Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 89EC96B0264
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 09:43:08 -0500 (EST)
Received: by ioir85 with SMTP id r85so58441325ioi.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 06:43:08 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id 99si670074iop.148.2015.11.13.06.43.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 06:43:07 -0800 (PST)
Date: Fri, 13 Nov 2015 08:43:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab/slub: adjust kmem_cache_alloc_bulk API
In-Reply-To: <20151113135746.5605.33090.stgit@firesoul>
Message-ID: <alpine.DEB.2.20.1511130842070.14950@east.gentwo.org>
References: <20151113135746.5605.33090.stgit@firesoul>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>

On Fri, 13 Nov 2015, Jesper Dangaard Brouer wrote:

> Adjust kmem_cache_alloc_bulk API before we have any real users.

Well yes that is what I initially proposed. There was a concern that the
_bulk calls should either return all objects or none.

But if you indicate that with a flag then ok.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
