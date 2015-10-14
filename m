Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2AB6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 22:35:52 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so39094095pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 19:35:51 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id hw8si9437243pac.167.2015.10.13.19.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 19:35:51 -0700 (PDT)
Received: by padcn9 with SMTP id cn9so7996787pad.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 19:35:51 -0700 (PDT)
Date: Tue, 13 Oct 2015 19:35:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] slab_common: rename cache create/destroy helpers
In-Reply-To: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
Message-ID: <alpine.DEB.2.10.1510131935380.12718@chino.kir.corp.google.com>
References: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Oct 2015, Vladimir Davydov wrote:

> do_kmem_cache_create, do_kmem_cache_shutdown, and do_kmem_cache_release
> sound awkward for static helper functions that are not supposed to be
> used outside slab_common.c. Rename them to create_cache, shutdown_cache,
> and release_caches, respectively. This patch is a pure cleanup and does
> not introduce any functional changes.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
