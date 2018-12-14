Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A58088E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 01:32:24 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v12so2931156plp.16
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 22:32:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n85sor6421811pfb.16.2018.12.13.22.32.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Dec 2018 22:32:23 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: remove unused page state adjustment macro
Date: Fri, 14 Dec 2018 14:32:11 +0800
Message-Id: <20181214063211.2290-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, Wei Yang <richard.weiyang@gmail.com>

These four macro are not used anymore.

Just remove them.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/vmstat.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index f25cef84b41d..2db8d60981fe 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -239,11 +239,6 @@ extern unsigned long node_page_state(struct pglist_data *pgdat,
 #define node_page_state(node, item) global_node_page_state(item)
 #endif /* CONFIG_NUMA */
 
-#define add_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, __d)
-#define sub_zone_page_state(__z, __i, __d) mod_zone_page_state(__z, __i, -(__d))
-#define add_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, __d)
-#define sub_node_page_state(__p, __i, __d) mod_node_page_state(__p, __i, -(__d))
-
 #ifdef CONFIG_SMP
 void __mod_zone_page_state(struct zone *, enum zone_stat_item item, long);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
-- 
2.15.1
