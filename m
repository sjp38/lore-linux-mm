Subject: [KJ PATCH] Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
	arch/i386/mm/pageattr.c.
From: Shani Moideen <shani.moideen@wipro.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 09 May 2007 17:27:19 +0530
Message-Id: <1178711839.2280.21.camel@shani-win>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-janitors@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hi,
 
Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
arch/i386/mm/pageattr.c.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/arch/i386/mm/pageattr.c b/arch/i386/mm/pageattr.c
index 412ebbd..12f7f14 100644
--- a/arch/i386/mm/pageattr.c
+++ b/arch/i386/mm/pageattr.c
@@ -45,7 +45,7 @@ static struct page *split_large_page(unsigned long address, pgprot_t prot,
 	pte_t *pbase;

 	spin_unlock_irq(&cpa_lock);
-	base = alloc_pages(GFP_KERNEL, 0);
+	base = alloc_page(GFP_KERNEL);
 	spin_lock_irq(&cpa_lock);
 	if (!base) 
 		return NULL;


-- 
Shani 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
