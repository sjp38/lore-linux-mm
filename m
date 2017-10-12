Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE216B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 06:06:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so11293336pff.1
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 03:06:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i8si12631415pll.306.2017.10.12.03.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 03:06:33 -0700 (PDT)
From: changbin.du@intel.com
Subject: [PATCH] mm, swap_state.c: declare a few variables as __read_mostly
Date: Thu, 12 Oct 2017 17:59:09 +0800
Message-Id: <1507802349-5554-1-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Changbin Du <changbin.du@intel.com>

From: Changbin Du <changbin.du@intel.com>

These global variables are only set during initialization or rarely
change, so declare them as __read_mostly.

Signed-off-by: Changbin Du <changbin.du@intel.com>
---
 mm/swap_state.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index ed91091..71e667d 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -35,13 +35,13 @@ static const struct address_space_operations swap_aops = {
 #endif
 };
 
-struct address_space *swapper_spaces[MAX_SWAPFILES];
-static unsigned int nr_swapper_spaces[MAX_SWAPFILES];
-bool swap_vma_readahead = true;
+struct address_space *swapper_spaces[MAX_SWAPFILES] __read_mostly;
+static unsigned int nr_swapper_spaces[MAX_SWAPFILES] __read_mostly;
+bool swap_vma_readahead __read_mostly = true;
 
 #define SWAP_RA_MAX_ORDER_DEFAULT	3
 
-static int swap_ra_max_order = SWAP_RA_MAX_ORDER_DEFAULT;
+static int swap_ra_max_order __read_mostly = SWAP_RA_MAX_ORDER_DEFAULT;
 
 #define SWAP_RA_WIN_SHIFT	(PAGE_SHIFT / 2)
 #define SWAP_RA_HITS_MASK	((1UL << SWAP_RA_WIN_SHIFT) - 1)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
