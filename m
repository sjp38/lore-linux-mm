Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 199E06B003D
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:46:42 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so7556660pbc.13
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:46:41 -0800 (PST)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id ay1si18564917pbd.246.2014.02.11.02.46.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 02:46:41 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so7601651pbb.9
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:46:40 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH 1/2] mm/zswap: fix trivial typo and arrange indentation
Date: Tue, 11 Feb 2014 19:46:29 +0900
Message-Id: <1392115590-15260-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, trivial@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/zswap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index e55bab9..5b22453 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -160,14 +160,14 @@ static void zswap_comp_exit(void)
  * rbnode - links the entry into red-black tree for the appropriate swap type
  * refcount - the number of outstanding reference to the entry. This is needed
  *            to protect against premature freeing of the entry by code
- *            concurent calls to load, invalidate, and writeback.  The lock
+ *            concurrent calls to load, invalidate, and writeback.  The lock
  *            for the zswap_tree structure that contains the entry must
  *            be held while changing the refcount.  Since the lock must
  *            be held, there is no reason to also make refcount atomic.
  * offset - the swap offset for the entry.  Index into the red-black tree.
  * handle - zsmalloc allocation handle that stores the compressed page data
  * length - the length in bytes of the compressed page data.  Needed during
- *           decompression
+ *          decompression
  */
 struct zswap_entry {
 	struct rb_node rbnode;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
