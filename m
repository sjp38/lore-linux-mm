Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7666B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:59:24 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so211979517wic.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 02:59:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ja14si26134390wic.18.2015.07.29.02.59.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 02:59:22 -0700 (PDT)
Subject: Re: [PATCH 08/10] mm, page_alloc: Remove MIGRATE_RESERVE
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-9-git-send-email-mgorman@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B8A3F3.6090107@suse.cz>
Date: Wed, 29 Jul 2015 11:59:15 +0200
MIME-Version: 1.0
In-Reply-To: <1437379219-9160-9-git-send-email-mgorman@suse.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 07/20/2015 10:00 AM, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
> 
> MIGRATE_RESERVE preserves an old property of the buddy allocator that existed
> prior to fragmentation avoidance -- min_free_kbytes worth of pages tended to
> remain free until the only alternative was to fail the allocation. At the

          ^ I think you meant contiguous instead of free? Is it because
splitting chooses lowest possible order, and grouping by mobility means you
might be splitting e.g. order-5 movable page instead of using order-0 unmovable
page? And that the fallback heuristics specifically select highest available
order? I think it's not that obvious, so worth mentioning.

> time it was discovered that high-order atomic allocations relied on this
> property so MIGRATE_RESERVE was introduced. A later patch will introduce
> an alternative MIGRATE_HIGHATOMIC so this patch deletes MIGRATE_RESERVE
> and supporting code so it'll be easier to review. Note that this patch
> in isolation may look like a false regression if someone was bisecting
> high-order atomic allocation failures.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
