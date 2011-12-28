Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 053846B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 22:08:03 -0500 (EST)
Received: by iacb35 with SMTP id b35so25440966iac.14
        for <linux-mm@kvack.org>; Tue, 27 Dec 2011 19:08:03 -0800 (PST)
Message-ID: <4EFA87E4.8040609@gmail.com>
Date: Wed, 28 Dec 2011 11:07:16 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm/migrate.c: remove the unused macro lru_to_page
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

lru_to_page is not used in mm/migrate.c. Drop it.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/migrate.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 640002a..99da494 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -39,8 +39,6 @@
 
 #include "internal.h"
 
-#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
-
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
