Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5586B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 09:03:42 -0500 (EST)
Received: by wmec201 with SMTP id c201so30995504wme.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:03:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id xv2si4478532wjc.80.2015.12.08.06.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 06:03:40 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: page_alloc: fix variable type in zonelist type iteration
Date: Tue,  8 Dec 2015 09:03:32 -0500
Message-Id: <1449583412-22740-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

/home/hannes/src/linux/linux/mm/page_alloc.c: In function a??build_zonelistsa??:
/home/hannes/src/linux/linux/mm/page_alloc.c:4171:16: warning: comparison between a??enum zone_typea?? and a??enum <anonymous>a?? [-Wenum-compare]
  for (i = 0; i < MAX_ZONELISTS; i++) {
                ^

MAX_ZONELISTS has never been of enum zone_type, probably gcc only
recently started including -Wenum-compare in -Wall.

Make i a simple int.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d06a7d0..d5f291b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4160,8 +4160,7 @@ static void set_zonelist_order(void)
 
 static void build_zonelists(pg_data_t *pgdat)
 {
-	int j, node, load;
-	enum zone_type i;
+	int i, j, node, load;
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
