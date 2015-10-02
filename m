Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id C7BC16B02A0
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 06:10:04 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so15031130igc.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 03:10:04 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id b9si5487644igl.46.2015.10.02.03.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 03:10:03 -0700 (PDT)
Date: Fri, 2 Oct 2015 05:10:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
In-Reply-To: <20151002114118.75aae2f9@redhat.com>
Message-ID: <alpine.DEB.2.20.1510020508580.2991@east.gentwo.org>
References: <560ABE86.9050508@gmail.com> <20150930114255.13505.2618.stgit@canyon> <20151001151015.c59a1360c7720a257f655578@linux-foundation.org> <20151002114118.75aae2f9@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Fri, 2 Oct 2015, Jesper Dangaard Brouer wrote:

> Thus, I need introducing new code like this patch and at the same time
> have to reduce the number of instruction-cache misses/usage.  In this
> case we solve the problem by kmem_cache_free_bulk() not getting called
> too often. Thus, +17 bytes will hopefully not matter too much... but on
> the other hand we sort-of know that calling kmem_cache_free_bulk() will
> cause icache misses.

Can we just drop the WARN/BUG here? Nothing untoward happens if size == 0
right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
