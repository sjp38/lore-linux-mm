Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 70C576B00B6
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:08:53 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so2718671pbc.11
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:08:53 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:08:49 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 08/15] slab: use __GFP_COMP flag for allocating slab
 pages
In-Reply-To: <1381913052-23875-9-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000141c7d1fae0-ff132cb2-5485-4b8f-9b22-d4da27068681-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1381913052-23875-9-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 16 Oct 2013, Joonsoo Kim wrote:

> If we use 'struct page' of first page as 'struct slab', there is no
> advantage not to use __GFP_COMP. So use __GFP_COMP flag for all the cases.

Yes this is going to make the allocators behave in the same way. We could
actually put some of the page allocator related functionality in
slab_common.c

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
