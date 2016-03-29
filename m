Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id C664E6B025E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 20:58:31 -0400 (EDT)
Received: by mail-io0-f178.google.com with SMTP id a129so4367132ioe.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 17:58:31 -0700 (PDT)
Received: from resqmta-po-12v.sys.comcast.net (resqmta-po-12v.sys.comcast.net. [2001:558:fe16:19:96:114:154:171])
        by mx.google.com with ESMTPS id 25si4717822ioj.47.2016.03.28.17.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 17:58:31 -0700 (PDT)
Date: Mon, 28 Mar 2016 19:58:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 05/11] mm/slab: clean-up kmem_cache_node setup
In-Reply-To: <1459142821-20303-6-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1603281957100.31323@east.gentwo.org>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com> <1459142821-20303-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Mar 2016, js1304@gmail.com wrote:

>   * This initializes kmem_cache_node or resizes various caches for all nodes.
>   */
> -static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
> +static int setup_kmem_cache_node_node(struct kmem_cache *cachep, gfp_t gfp)

... _node_node? Isnt there a better name for it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
