Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA65C6B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 21:03:24 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id tr6so1045889ieb.10
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:03:24 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id c7si3108358icb.102.2014.06.24.18.03.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 18:03:24 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so989360iec.23
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:03:24 -0700 (PDT)
Date: Tue, 24 Jun 2014 18:03:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: fix off by one in number of slab tests
In-Reply-To: <1403595842-28270-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.02.1406241801240.22030@chino.kir.corp.google.com>
References: <1403595842-28270-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue, 24 Jun 2014, Joonsoo Kim wrote:

> min_partial means minimum number of slab cached in node partial
> list. So, if nr_partial is less than it, we keep newly empty slab
> on node partial list rather than freeing it. But if nr_partial is
> equal or greater than it, it means that we have enough partial slabs
> so should free newly empty slab. Current implementation missed
> the equal case so if we set min_partial is 0, then, at least one slab
> could be cached. This is critical problem to kmemcg destroying logic
> because it doesn't works properly if some slabs is cached. This patch
> fixes this problem.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

Needed for 3.16 to fix commit 91cb69620284 ("slub: make dead memcg caches 
discard free slabs immediately").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
