Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E51D36B0044
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:46:47 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so6937344pdb.24
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:46:47 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id qx4si18566193pbc.135.2014.02.11.02.46.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 02:46:47 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so7424612pab.5
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:46:46 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH 2/2] mm/zswap: update zsmalloc in comment to zbud
Date: Tue, 11 Feb 2014 19:46:30 +0900
Message-Id: <1392115590-15260-2-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1392115590-15260-1-git-send-email-sj38.park@gmail.com>
References: <1392115590-15260-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, trivial@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

zswap used zsmalloc before and now using zbud. But, some comments
saying it use zsmalloc yet. Fix the trivial problems.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/zswap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 5b22453..25312eb 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -165,7 +165,7 @@ static void zswap_comp_exit(void)
  *            be held while changing the refcount.  Since the lock must
  *            be held, there is no reason to also make refcount atomic.
  * offset - the swap offset for the entry.  Index into the red-black tree.
- * handle - zsmalloc allocation handle that stores the compressed page data
+ * handle - zbud allocation handle that stores the compressed page data
  * length - the length in bytes of the compressed page data.  Needed during
  *          decompression
  */
@@ -282,7 +282,7 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
 }
 
 /*
- * Carries out the common pattern of freeing and entry's zsmalloc allocation,
+ * Carries out the common pattern of freeing and entry's zbud allocation,
  * freeing the entry itself, and decrementing the number of stored pages.
  */
 static void zswap_free_entry(struct zswap_tree *tree,
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
