Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0548E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 18:35:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id bg5-v6so12109799plb.20
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 15:35:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1-v6sor3594499plk.27.2018.09.11.15.35.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 15:35:15 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v7 2/6] mm: export add_swap_extent()
Date: Tue, 11 Sep 2018 15:34:45 -0700
Message-Id: <bb1208575e02829aae51b538709476964f97b1ea.1536704650.git.osandov@fb.com>
In-Reply-To: <cover.1536704650.git.osandov@fb.com>
References: <cover.1536704650.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org
Cc: kernel-team@fb.com, linux-mm@kvack.org

From: Omar Sandoval <osandov@fb.com>

Btrfs will need this for swap file support.

Signed-off-by: Omar Sandoval <osandov@fb.com>
---
 mm/swapfile.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index d3f95833d12e..51cb30de17bc 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2365,6 +2365,7 @@ add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
 	list_add_tail(&new_se->list, &sis->first_swap_extent.list);
 	return 1;
 }
+EXPORT_SYMBOL_GPL(add_swap_extent);
 
 /*
  * A `swap extent' is a simple thing which maps a contiguous range of pages
-- 
2.18.0
