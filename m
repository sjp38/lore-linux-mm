Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id B3FA36B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:22:48 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so44212949ieb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:22:48 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id b19si5092376igr.21.2015.06.17.16.22.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 16:22:48 -0700 (PDT)
Received: by igbiq7 with SMTP id iq7so79152186igb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:22:48 -0700 (PDT)
Date: Wed, 17 Jun 2015 16:22:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 3/5] mm/dmapool: allow NULL `pool' pointer in
 dma_pool_destroy()
In-Reply-To: <1433851493-23685-4-git-send-email-sergey.senozhatsky@gmail.com>
Message-ID: <alpine.DEB.2.10.1506171621400.8203@chino.kir.corp.google.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <1433851493-23685-4-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Tue, 9 Jun 2015, Sergey Senozhatsky wrote:

> dma_pool_destroy() does not tolerate a NULL dma_pool pointer
> argument and performs a NULL-pointer dereference. This requires
> additional attention and effort from developers/reviewers and
> forces all dma_pool_destroy() callers to do a NULL check
> 
> 	if (pool)
> 		dma_pool_destroy(pool);
> 
> Or, otherwise, be invalid dma_pool_destroy() users.
> 
> Tweak dma_pool_destroy() and NULL-check the pointer there.
> 
> Proposed by Andrew Morton.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> LKML-reference: https://lkml.org/lkml/2015/6/8/583

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
