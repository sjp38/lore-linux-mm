Subject: [KJ PATCH] Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
	arch/i386/mm/pgtable.c.
From: Shani Moideen <shani.moideen@wipro.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 09 May 2007 17:30:41 +0530
Message-Id: <1178712041.2280.25.camel@shani-win>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-janitors@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hi,
 
Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
arch/i386/mm/pgtable.c.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/arch/i386/mm/pgtable.c b/arch/i386/mm/pgtable.c
index fa0cfbd..5d2b0fb 100644
--- a/arch/i386/mm/pgtable.c
+++ b/arch/i386/mm/pgtable.c
@@ -191,9 +191,9 @@ struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	struct page *pte;

 #ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO, 0);
+	pte = alloc_page(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO);
 #else
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	pte = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
 #endif
 	return pte;
 }

-- 
Shani 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
