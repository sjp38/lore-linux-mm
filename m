Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id BF795900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 14:09:20 -0400 (EDT)
Received: by wesq59 with SMTP id q59so11073789wes.9
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 11:09:20 -0700 (PDT)
Received: from mailrelay109.isp.belgacom.be (mailrelay109.isp.belgacom.be. [195.238.20.136])
        by mx.google.com with ESMTP id cq7si373804wjc.34.2015.03.11.11.09.18
        for <linux-mm@kvack.org>;
        Wed, 11 Mar 2015 11:09:19 -0700 (PDT)
From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] mm/page_alloc.c: don't redeclare mt in get_pageblock_migratetype()
Date: Wed, 11 Mar 2015 19:08:53 +0100
Message-Id: <1426097333-24131-1-git-send-email-fabf@skynet.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>, linux-mm@kvack.org

mt is already declared above and global value not used after loop.
This fixes a shadow warning.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b84950..4ec8c23 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1653,7 +1653,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
-			int mt = get_pageblock_migratetype(page);
+			mt = get_pageblock_migratetype(page);
 			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
