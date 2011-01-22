Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CC1988D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 19:07:10 -0500 (EST)
Received: by gwj22 with SMTP id 22so756985gwj.14
        for <linux-mm@kvack.org>; Fri, 21 Jan 2011 16:07:09 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] migration: clear migrate_pages's comment
Date: Sat, 22 Jan 2011 09:06:52 +0900
Message-Id: <1295654812-2108-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Callers of migrate_pages should putback_lru_pages to return pages
isolated to LRU or free list. Now comment is rather confusing.
It says caller always have to call it.
More clear thing is that caller have to call it if migrate_pages's 
return value isn't zero.

Cc: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/migrate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 3a6d4fd..7661152 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -887,7 +887,7 @@ out:
  * are movable anymore because to has become empty
  * or no retryable pages exist anymore.
  * Caller should call putback_lru_pages to return pages to the LRU
- * or free list.
+ * or free list only if ret != 0.
  *
  * Return: Number of pages not migrated or error code.
  */
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
