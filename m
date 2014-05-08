Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5FB6B00B3
	for <linux-mm@kvack.org>; Wed,  7 May 2014 21:01:56 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so1916911pab.1
        for <linux-mm@kvack.org>; Wed, 07 May 2014 18:01:55 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id wt1si2710695pbc.376.2014.05.07.18.01.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 18:01:53 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so635504pad.41
        for <linux-mm@kvack.org>; Wed, 07 May 2014 18:01:53 -0700 (PDT)
Date: Wed, 7 May 2014 18:01:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 04/10] slab: defer slab_destroy in free_block()
In-Reply-To: <1399442780-28748-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1405071801040.1128@chino.kir.corp.google.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com> <1399442780-28748-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Wed, 7 May 2014, Joonsoo Kim wrote:

> In free_block(), if freeing object makes new free slab and number of
> free_objects exceeds free_limit, we start to destroy this new free slab
> with holding the kmem_cache node lock. Holding the lock is useless and,
> generally, holding a lock as least as possible is good thing. I never
> measure performance effect of this, but we'd be better not to hold the lock
> as much as possible.
> 
> Commented by Christoph:
>   This is also good because kmem_cache_free is no longer called while
>   holding the node lock. So we avoid one case of recursion.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

Nice optimization.  I think it could have benefited from a comment 
describing what the free_block() list formal is, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
