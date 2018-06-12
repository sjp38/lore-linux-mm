Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 395306B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 14:00:02 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id n23-v6so6510503uao.15
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:00:02 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x4-v6si234713uan.57.2018.06.12.11.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 11:00:00 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [PATCH] mm, swap: fix swap_count comment about nonexistent SWAP_HAS_CONT
Date: Tue, 12 Jun 2018 13:59:19 -0400
Message-Id: <20180612175919.30413-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ying.huang@intel.com, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, daniel.m.jordan@oracle.com

570a335b8e22 ("swap_info: swap count continuations") introduces
COUNT_CONTINUED but refers to it incorrectly as SWAP_HAS_CONT in a
comment in swap_count.  Fix it.

Fixes: 570a335b8e22 ("swap_info: swap count continuations")
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: "Huang, Ying" <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/swapfile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 744d66666f82..808349ee6f6f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -101,7 +101,7 @@ atomic_t nr_rotate_swap = ATOMIC_INIT(0);
 
 static inline unsigned char swap_count(unsigned char ent)
 {
-	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
+	return ent & ~SWAP_HAS_CACHE;	/* may include COUNT_CONTINUED flag */
 }
 
 /* returns 1 if swap entry is freed */
-- 
2.17.0
