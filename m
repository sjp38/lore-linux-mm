Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2DC66B03D0
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:14:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v60so29082052wrc.7
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 03:14:49 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id k75si16201542wmc.87.2017.06.21.03.14.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 03:14:48 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH][mm-next] mm: clean up build warning with unused variable ret2
Date: Wed, 21 Jun 2017 11:14:33 +0100
Message-Id: <20170621101433.9847-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <dchinner@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Variable ret2 is unused and should be removed. Cleans up
build warning:

warning: unused variable 'ret2' [-Wunused-variable]

Fixes: 4118ba44fa2cd040e ("mm: clean up error handling in write_one_page")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
