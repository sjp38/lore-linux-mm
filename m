Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 604B46B7D2E
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 03:39:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m4-v6so6821318pgq.19
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 00:39:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10-v6sor1634513pll.123.2018.09.07.00.39.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 00:39:38 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v6 2/6] mm: export add_swap_extent()
Date: Fri,  7 Sep 2018 00:39:16 -0700
Message-Id: <6846192edded07fb0cccf11ef37aebd4822275a1.1536305017.git.osandov@fb.com>
In-Reply-To: <cover.1536305017.git.osandov@fb.com>
References: <cover.1536305017.git.osandov@fb.com>
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
