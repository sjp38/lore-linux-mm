Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6F8E6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 18:13:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so25365086pfj.4
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 15:13:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s14sor2372plp.23.2017.09.27.15.13.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 15:13:16 -0700 (PDT)
From: Tahsin Erdogan <tahsin@google.com>
Subject: [PATCH] writeback: remove unused parameter from balance_dirty_pages()
Date: Wed, 27 Sep 2017 15:13:11 -0700
Message-Id: <20170927221311.23263-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Jeff Layton <jlayton@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Theodore Ts'o <tytso@mit.edu>, Nikolay Borisov <nborisov@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tahsin Erdogan <tahsin@google.com>

"mapping" parameter to balance_dirty_pages() is not used anymore.

Fixes: dfb8ae567835 ("writeback: let balance_dirty_pages() work on the matching cgroup bdi_writeback")

Signed-off-by: Tahsin Erdogan <tahsin@google.com>
---
 mm/page-writeback.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b9c5cbe8eba..d89663f00e93 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1559,8 +1559,7 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
  * If we're over `background_thresh' then the writeback threads are woken to
  * perform some writeout.
  */
-static void balance_dirty_pages(struct address_space *mapping,
-				struct bdi_writeback *wb,
+static void balance_dirty_pages(struct bdi_writeback *wb,
 				unsigned long pages_dirtied)
 {
 	struct dirty_throttle_control gdtc_stor = { GDTC_INIT(wb) };
@@ -1910,7 +1909,7 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 	preempt_enable();
 
 	if (unlikely(current->nr_dirtied >= ratelimit))
-		balance_dirty_pages(mapping, wb, current->nr_dirtied);
+		balance_dirty_pages(wb, current->nr_dirtied);
 
 	wb_put(wb);
 }
-- 
2.14.2.822.g60be5d43e6-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
