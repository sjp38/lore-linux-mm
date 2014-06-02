Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE296B0037
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:45:05 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id dc16so2952349qab.28
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:45:04 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id g62si17956814qgf.39.2014.06.02.08.45.04
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:45:04 -0700 (PDT)
Date: Mon, 2 Jun 2014 10:45:01 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 4/4] slab: Use for_each_kmem_cache_node function
In-Reply-To: <20140602051254.GD17964@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1406021043160.2987@gentwo.org>
References: <20140530182753.191965442@linux.com> <20140530182801.678250467@linux.com> <20140602051254.GD17964@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Mon, 2 Jun 2014, Joonsoo Kim wrote:

> There are some other places that we can replace such as get_slabinfo(),
> leaks_show(), etc.. If you want to replace for_each_online_node()
> with for_each_kmem_cache_node, please also replace them.

Ok we can do that.

> Meanwhile, I think that this change is not good for readability. There
> are many for_each_online_node() usage that we can't replace, so I don't
> think this abstraction is really helpful clean-up. Possibly, using
> for_each_online_node() consistently would be more readable than this
> change.

What really matters is that we have a management structure kmem_cache_node
for the relevant node. There are portions during bootstrap when
kmem_cache_node is not allocated. Using this function also avoids race
conditions during node bringup and teardown.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
