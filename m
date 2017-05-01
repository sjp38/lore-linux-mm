Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D19B66B02F4
	for <linux-mm@kvack.org>; Mon,  1 May 2017 02:35:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q66so68384664pfi.16
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:35:03 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id n63si13379094pga.62.2017.04.30.23.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 23:35:03 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id t7so14919897pgt.1
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 23:35:03 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH v2 3/3] powerpc/mm/hugetlb: Add support for page accounting
Date: Mon,  1 May 2017 16:34:38 +1000
Message-Id: <20170501063438.25237-4-bsingharora@gmail.com>
In-Reply-To: <20170501063438.25237-1-bsingharora@gmail.com>
References: <20170501063438.25237-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov@virtuozzo.com, mpe@ellerman.id.au, oss@buserror.net
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>

Add __GFP_ACCOUNT to __hugepte_alloc()

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 arch/powerpc/mm/hugetlbpage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a4f33de..94e56b1 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -77,7 +77,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 		num_hugepd = 1;
 	}
 
-	new = kmem_cache_zalloc(cachep, GFP_KERNEL);
+	new = kmem_cache_zalloc(cachep, pgtable_gfp_flags(mm, GFP_KERNEL));
 
 	BUG_ON(pshift > HUGEPD_SHIFT_MASK);
 	BUG_ON((unsigned long)new & HUGEPD_SHIFT_MASK);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
