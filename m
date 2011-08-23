Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1DE7F90013A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 04:56:55 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 06/13] shrinker: remove old API now it is unused
Date: Tue, 23 Aug 2011 18:56:19 +1000
Message-Id: <1314089786-20535-7-git-send-email-david@fromorbit.com>
In-Reply-To: <1314089786-20535-1-git-send-email-david@fromorbit.com>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

From: Dave Chinner <dchinner@redhat.com>

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/shrinker.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 50f213f..ab6c572 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -20,11 +20,6 @@ struct shrink_control {
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
- * @shrink() should look through the least-recently-used 'nr_to_scan' entries
- * and attempt to free them up.  It should return the number of objects which
- * remain in the cache.  If it returns -1, it means it cannot do any scanning at
- * this time (eg. there is a risk of deadlock).
- *
  * @count_objects should return the number of freeable items in the cache. If
  * there are no objects to free or the number of freeable items cannot be
  * determined, it should return 0. No deadlock checks should be done during the
@@ -40,7 +35,6 @@ struct shrink_control {
  * @scan_objects will be made from the current reclaim context.
  */
 struct shrinker {
-	int (*shrink)(struct shrinker *, struct shrink_control *sc);
 	long (*count_objects)(struct shrinker *, struct shrink_control *sc);
 	long (*scan_objects)(struct shrinker *, struct shrink_control *sc);
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
