Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id D0F226B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 00:45:20 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MPT00AET3VCTED0@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 12 Jul 2013 13:45:12 +0900 (KST)
From: Sunghan Suh <sunghan.suh@samsung.com>
Subject: [PATCH] zswap: get swapper address_space by using swap_address_space
 macro
Date: Fri, 12 Jul 2013 13:42:55 +0900
Message-id: <1373604175-19562-1-git-send-email-sunghan.suh@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org
Cc: Sunghan Suh <sunghan.suh@samsung.com>

Signed-off-by: Sunghan Suh <sunghan.suh@samsung.com>
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
