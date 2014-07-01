Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id DA4396B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 18:25:07 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id h18so5972337igc.13
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:25:07 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id ii2si18352754igb.62.2014.07.01.15.25.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 15:25:06 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so704844ier.40
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:25:06 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:25:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/9] slab: defer slab_destroy in free_block()
In-Reply-To: <1404203258-8923-4-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1407011524210.4004@chino.kir.corp.google.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com> <1404203258-8923-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, 1 Jul 2014, Joonsoo Kim wrote:

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

Not sure what happened to my

Acked-by: David Rientjes <rientjes@google.com>

from http://marc.info/?l=linux-kernel&m=139951092124314, and for the 
record, I still think the free_block() "list" formal should be commented.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
