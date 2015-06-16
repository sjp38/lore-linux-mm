Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 413FF6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 11:05:09 -0400 (EDT)
Received: by qgal13 with SMTP id l13so5765060qga.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:05:09 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id u18si1199792qgd.7.2015.06.16.08.05.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 08:05:08 -0700 (PDT)
Date: Tue, 16 Jun 2015 10:05:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/7] slub bulk alloc: extract objects from the per cpu
 slab
In-Reply-To: <20150616072107.GA13125@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1506161003480.3496@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155207.18824.8674.stgit@devil> <20150616072107.GA13125@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>

On Tue, 16 Jun 2015, Joonsoo Kim wrote:

> Now I found that we need to call slab_pre_alloc_hook() before any operation
> on kmem_cache to support kmemcg accounting. And, we need to call
> slab_post_alloc_hook() on every allocated objects to support many
> debugging features like as kasan and kmemleak

Use the fallback function for any debugging avoids that. This needs to be
fast. If the performance is not wanted (debugging etc active) then the
fallback should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
