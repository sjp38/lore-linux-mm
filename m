Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 515C76B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:36:12 -0500 (EST)
Date: Tue, 15 Jan 2013 15:36:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: correct bootstrap() for kmem_cache,
 kmem_cache_node
In-Reply-To: <1358234402-2615-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <0000013c3eda78d8-da8c775c-d7c0-4a88-bacf-0b5160b5c668-000000@email.amazonses.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com> <1358234402-2615-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 15 Jan 2013, Joonsoo Kim wrote:

> These didn't make any error previously, because we normally don't free
> objects which comes from kmem_cache's first slab and kmem_cache_node's.

And these slabs are on the partial list because the objects are typically
relatively small compared to page size. Do you have a system with a very
large kmem_cache size?

> Problem will be solved if we consider a cpu slab in bootstrap().
> This patch implement it.

At boot time only one processor is up so you do not need the loop over all
processors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
