Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96E4B6B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 13:18:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y142so9631698wme.12
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 10:18:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k135sor1900435wmd.68.2017.10.16.10.18.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 10:18:00 -0700 (PDT)
Date: Mon, 16 Oct 2017 19:17:57 +0200
From: Laszlo Toth <laszlth@gmail.com>
Subject: [PATCH] mm, soft_offline: improve hugepage soft offlining error log
Message-ID: <20171016171757.GA3018@ubuntu-desk-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On a failed attempt, we get the following entry:
soft offline: 0x3c0000: migration failed 1, type 17ffffc0008008
(uptodate|head)

Make this more specific to be straightforward and to follow
other error log formats in soft_offline_huge_page().

Signed-off-by: Laszlo Toth <laszlth@gmail.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8836662..4acdf39 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1587,7 +1587,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 				MIGRATE_SYNC, MR_MEMORY_FAILURE);
 	if (ret) {
-		pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
+		pr_info("soft offline: %#lx: hugepage migration failed %d, type %lx (%pGp)\n",
 			pfn, ret, page->flags, &page->flags);
 		if (!list_empty(&pagelist))
 			putback_movable_pages(&pagelist);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
