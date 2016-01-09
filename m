Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7C56B025E
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 08:41:55 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id f206so208467008wmf.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 05:41:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q124si6631113wmd.110.2016.01.09.05.41.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 09 Jan 2016 05:41:53 -0800 (PST)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH v2] lib+mm: fix few spelling mistakes
Date: Sat,  9 Jan 2016 14:41:51 +0100
Message-Id: <1452346911-8983-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org
Cc: linux-kernel@vger.kernel.org, Bogdan Sikora <bsikora@redhat.com>, linux-mm@kvack.org, Kent Overstreet <kmo@daterainc.com>, Jan Kara <jack@suse.cz>, Jiri Slaby <jslaby@suse.cz>

From: Bogdan Sikora <bsikora@redhat.com>

All are in comments.

[v2] also s/moduler/modular/

Signed-off-by: Bogdan Sikora <bsikora@redhat.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
Cc: <linux-mm@kvack.org>
Cc: Kent Overstreet <kmo@daterainc.com>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 lib/flex_proportions.c  | 2 +-
 lib/percpu-refcount.c   | 2 +-
 mm/balloon_compaction.c | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
index 8f25652f40d4..a71cf1bdd4c9 100644
--- a/lib/flex_proportions.c
+++ b/lib/flex_proportions.c
@@ -17,7 +17,7 @@
  *
  *   \Sum_{j} p_{j} = 1,
  *
- * This formula can be straightforwardly computed by maintaing denominator
+ * This formula can be straightforwardly computed by maintaining denominator
  * (let's call it 'd') and for each event type its numerator (let's call it
  * 'n_j'). When an event of type 'j' happens, we simply need to do:
  *   n_j++; d++;
diff --git a/lib/percpu-refcount.c b/lib/percpu-refcount.c
index 6111bcb28376..27fe74948882 100644
--- a/lib/percpu-refcount.c
+++ b/lib/percpu-refcount.c
@@ -12,7 +12,7 @@
  * particular cpu can (and will) wrap - this is fine, when we go to shutdown the
  * percpu counters will all sum to the correct value
  *
- * (More precisely: because moduler arithmatic is commutative the sum of all the
+ * (More precisely: because modular arithmetic is commutative the sum of all the
  * percpu_count vars will be equal to what it would have been if all the gets
  * and puts were done to a single integer, even if some of the percpu integers
  * overflow or underflow).
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 66d69c52a6d3..63e1dc11a580 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -13,10 +13,10 @@
 /*
  * balloon_page_enqueue - allocates a new page and inserts it into the balloon
  *			  page list.
- * @b_dev_info: balloon device decriptor where we will insert a new page to
+ * @b_dev_info: balloon device descriptor where we will insert a new page to
  *
  * Driver must call it to properly allocate a new enlisted balloon page
- * before definetively removing it from the guest system.
+ * before definitively removing it from the guest system.
  * This function returns the page address for the recently enqueued page or
  * NULL in the case we fail to allocate a new page this turn.
  */
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
