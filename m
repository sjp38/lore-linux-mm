Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 16BC66B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 23:13:03 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7Y003993LOCC00@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 30 Aug 2010 04:13:00 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Y002HM3LNV4@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 30 Aug 2010 04:13:00 +0100 (BST)
Date: Mon, 30 Aug 2010 05:12:20 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH] mm: pageblock-flags.h: dead code removed
Message-id: 
 <ced62161886b800e8f0706cc6a17786d69f4200a.1283137455.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <mina86@mina86.com>

This commit removes two unused macros one of which was, as
a matter of fact, invalid.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/pageblock-flags.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index e8c0612..0949302 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -65,9 +65,4 @@ unsigned long get_pageblock_flags_group(struct page *page,
 void set_pageblock_flags_group(struct page *page, unsigned long flags,
 					int start_bitidx, int end_bitidx);
 
-#define get_pageblock_flags(page) \
-			get_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
-#define set_pageblock_flags(page) \
-			set_pageblock_flags_group(page, 0, NR_PAGEBLOCK_BITS-1)
-
 #endif	/* PAGEBLOCK_FLAGS_H */
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
