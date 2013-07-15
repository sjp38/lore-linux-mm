Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 15D126B007D
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 20:53:39 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MPY00DKVD57D660@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 15 Jul 2013 09:53:37 +0900 (KST)
From: Sunghan Suh <sunghan.suh@samsung.com>
Subject: [PATCH] zswap: get swapper address_space by using macro
Date: Mon, 15 Jul 2013 09:53:17 +0900
Message-id: <1373849597-29631-1-git-send-email-sunghan.suh@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sjenning@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, Sunghan Suh <sunghan.suh@samsung.com>

There is a proper macro to get the corresponding swapper address space from a swap entry.
Instead of directly accessing "swapper_spaces" array, use the "swap_address_space" macro.

Signed-off-by: Sunghan Suh <sunghan.suh@samsung.com>
Reviewed-by: Bob Liu <bob.liu@oracle.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 mm/zswap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..efed4c8 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -409,7 +409,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 				struct page **retpage)
 {
 	struct page *found_page, *new_page = NULL;
-	struct address_space *swapper_space = &swapper_spaces[swp_type(entry)];
+	struct address_space *swapper_space = swap_address_space(entry);
 	int err;
 
 	*retpage = NULL;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
