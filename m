Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AFAA7829A8
	for <linux-mm@kvack.org>; Sat, 23 May 2015 01:11:01 -0400 (EDT)
Received: by paza2 with SMTP id a2so25269720paz.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 22:11:01 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id i4si6450704pdn.107.2015.05.22.22.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 22:11:00 -0700 (PDT)
Received: by padbw4 with SMTP id bw4so34553710pad.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 22:11:00 -0700 (PDT)
From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] mm:cma - Fix for typos in comments.
Date: Sat, 23 May 2015 10:40:47 +0530
Message-Id: <1432357847-4434-1-git-send-email-shailendra.capricorn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Shailendra Verma <shailendra.capricorn@gmail.com>


Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 mm/cma.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 3a7a67b..6612780 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -182,7 +182,7 @@ int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 	if (!size || !memblock_is_region_reserved(base, size))
 		return -EINVAL;
 
-	/* ensure minimal alignment requied by mm core */
+	/* ensure minimal alignment required by mm core */
 	alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
 
 	/* alignment should be aligned with order_per_bit */
@@ -238,7 +238,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	/*
 	 * high_memory isn't direct mapped memory so retrieving its physical
 	 * address isn't appropriate.  But it would be useful to check the
-	 * physical address of the highmem boundary so it's justfiable to get
+	 * physical address of the highmem boundary so it's justifiable to get
 	 * the physical address from it.  On x86 there is a validation check for
 	 * this case, so the following workaround is needed to avoid it.
 	 */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
