Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A39926B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:07:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l34so34412751wrc.12
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 15:07:52 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.134])
        by mx.google.com with ESMTPS id f4si17201301wma.181.2017.06.21.15.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 15:07:51 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: page-writeback: remove unused variable
Date: Thu, 22 Jun 2017 00:02:12 +0200
Message-Id: <20170621220231.4127077-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A commit in today's file-locks/linux-next branch caused a warning
by introducing an unused variable:

mm/page-writeback.c: In function 'write_one_page':
mm/page-writeback.c:2380:15: warning: unused variable 'ret2' [-Wunused-variable]

Fixes: 4118ba44fa2c ("mm: clean up error handling in write_one_page")
Cc: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/page-writeback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 64b75bd996a4..0b60cc7ddac2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2377,7 +2377,7 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 int write_one_page(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
-	int ret = 0, ret2;
+	int ret = 0;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 1,
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
