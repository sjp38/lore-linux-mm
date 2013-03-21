Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0C2626B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 00:16:42 -0400 (EDT)
Message-ID: <514A898A.7010300@huawei.com>
Date: Thu, 21 Mar 2013 12:16:10 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/migrate: fix comment typo syncronous->synchronous
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, qiuxishi <qiuxishi@huawei.com>

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/migrate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 3bbaf5d..c87ef92 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -736,7 +736,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 
 	if (PageWriteback(page)) {
 		/*
-		 * Only in the case of a full syncronous migration is it
+		 * Only in the case of a full synchronous migration is it
 		 * necessary to wait for PageWriteback. In the async case,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
