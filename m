Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A80D76B02FA
	for <linux-mm@kvack.org>; Tue,  2 May 2017 01:17:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b17so79151926pfd.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 22:17:32 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id 62si16239355ply.117.2017.05.01.22.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 22:17:31 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id v14so30531777pfd.3
        for <linux-mm@kvack.org>; Mon, 01 May 2017 22:17:31 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [PATCH v3 3/3] powerpc/mm/hugetlb: Add support for page accounting
Date: Tue,  2 May 2017 15:17:06 +1000
Message-Id: <20170502051706.19043-4-bsingharora@gmail.com>
In-Reply-To: <20170502051706.19043-1-bsingharora@gmail.com>
References: <20170502051706.19043-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, mpe@ellerman.id.au, oss@buserror.net
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
