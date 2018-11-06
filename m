Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0987A6B0336
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 10:03:13 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f9so3848679pgs.13
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 07:03:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n27-v6sor38081092pfb.48.2018.11.06.07.03.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 07:03:11 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/slub: page is always non-NULL for node_match()
Date: Tue,  6 Nov 2018 23:02:45 +0800
Message-Id: <20181106150245.1668-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

node_match() is a static function and only invoked in slub.c.

In all three places, page is ensured to be valid.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 90d26063be68..af8bea511855 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2365,7 +2365,7 @@ static int slub_cpu_dead(unsigned int cpu)
 static inline int node_match(struct page *page, int node)
 {
 #ifdef CONFIG_NUMA
-	if (!page || (node != NUMA_NO_NODE && page_to_nid(page) != node))
+	if (node != NUMA_NO_NODE && page_to_nid(page) != node)
 		return 0;
 #endif
 	return 1;
-- 
2.15.1
