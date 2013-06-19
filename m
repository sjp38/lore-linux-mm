Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 309776B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 02:56:06 -0400 (EDT)
Message-ID: <51C155D1.3090304@asianux.com>
Date: Wed, 19 Jun 2013 14:55:13 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/vmscan.c: 'lru' may be used without initialized after
 the patch "3abf380..." in next-20130607 tree
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


'lru' may be used without initialized, so need regressing part of the
related patch.

The related patch:
  "3abf380 mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/vmscan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fe73724..e92b1858 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -595,6 +595,7 @@ redo:
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
+		lru = !!TestClearPageActive(page) + page_lru_base_type(page);
 		lru_cache_add(page);
 	} else {
 		/*
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
