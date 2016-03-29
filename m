Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 539496B025E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 20:56:18 -0400 (EDT)
Received: by mail-io0-f171.google.com with SMTP id a129so4321521ioe.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 17:56:18 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id w63si25613141iod.140.2016.03.28.17.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 17:56:17 -0700 (PDT)
Date: Mon, 28 Mar 2016 19:56:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 04/11] mm/slab: factor out kmem_cache_node initialization
 code
In-Reply-To: <1459142821-20303-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1603281955300.31323@east.gentwo.org>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com> <1459142821-20303-5-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Mar 2016, js1304@gmail.com wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> -		spin_lock_irq(&n->list_lock);
> -		n->free_limit =
> -			(1 + nr_cpus_node(node)) *
> -			cachep->batchcount + cachep->num;
> -		spin_unlock_irq(&n->list_lock);
> +		ret = init_cache_node(cachep, node, GFP_KERNEL);
> +		if (ret)
> +			return ret;

Drop ret and do a

	return init_cache_node(...);

instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
