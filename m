Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD5C6B0035
	for <linux-mm@kvack.org>; Sun, 28 Sep 2014 23:30:53 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so69491pdj.3
        for <linux-mm@kvack.org>; Sun, 28 Sep 2014 20:30:53 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0143.outbound.protection.outlook.com. [157.56.110.143])
        by mx.google.com with ESMTPS id je1si20830120pbb.168.2014.09.28.20.30.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 28 Sep 2014 20:30:52 -0700 (PDT)
From: Xiubo Li <Li.Xiubo@freescale.com>
Subject: [PATCH] mm, compaction: using uninitialized_var insteads setting 'flags' to 0 directly.
Date: Mon, 29 Sep 2014 11:30:25 +0800
Message-ID: <1411961425-8045-1-git-send-email-Li.Xiubo@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, vbabka@suse.cz, mgorman@suse.de, rientjes@google.com, minchan@kernel.org, Xiubo Li <Li.Xiubo@freescale.com>

Setting 'flags' to zero will be certainly a misleading way to avoid
warning of 'flags' may be used uninitialized. uninitialized_var is
a correct way because the warning is a false possitive.

Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
---
 mm/compaction.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 92075d5..59a116d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -344,7 +344,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 {
 	int nr_scanned = 0, total_isolated = 0;
 	struct page *cursor, *valid_page = NULL;
-	unsigned long flags = 0;
+	unsigned long uninitialized_var(flags);
 	bool locked = false;
 	unsigned long blockpfn = *start_pfn;
 
@@ -573,7 +573,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	struct lruvec *lruvec;
-	unsigned long flags = 0;
+	unsigned long uninitialized_var(flags);
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 
-- 
2.1.0.27.g96db324

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
