Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7F31E6B0098
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 20:49:35 -0400 (EDT)
Received: by mail-yh0-f41.google.com with SMTP id v1so9875898yhn.14
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 17:49:35 -0700 (PDT)
Received: from mail-yh0-x24a.google.com (mail-yh0-x24a.google.com [2607:f8b0:4002:c01::24a])
        by mx.google.com with ESMTPS id k22si305724yhj.107.2014.04.01.17.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 17:49:35 -0700 (PDT)
Received: by mail-yh0-f74.google.com with SMTP id f10so1468769yha.3
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 17:49:35 -0700 (PDT)
References: <cover.1396335798.git.vdavydov@parallels.com> <031f9e2374dcb4cb6c2e7d509d1276623d5b1fba.1396335798.git.vdavydov@parallels.com>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH -mm v2 1/2] sl[au]b: charge slabs to kmemcg explicitly
In-reply-to: <031f9e2374dcb4cb6c2e7d509d1276623d5b1fba.1396335798.git.vdavydov@parallels.com>
Date: Tue, 01 Apr 2014 17:49:34 -0700
Message-ID: <xr938urok129.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org


On Tue, Apr 01 2014, Vladimir Davydov <vdavydov@parallels.com> wrote:

> We have only a few places where we actually want to charge kmem so
> instead of intruding into the general page allocation path with
> __GFP_KMEMCG it's better to explictly charge kmem there. All kmem
> charges will be easier to follow that way.
>
> This is a step towards removing __GFP_KMEMCG. It removes __GFP_KMEMCG
> from memcg caches' allocflags. Instead it makes slab allocation path
> call memcg_charge_kmem directly getting memcg to charge from the cache's
> memcg params.
>
> This also eliminates any possibility of misaccounting an allocation
> going from one memcg's cache to another memcg, because now we always
> charge slabs against the memcg the cache belongs to. That's why this
> patch removes the big comment to memcg_kmem_get_cache.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
