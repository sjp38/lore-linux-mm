Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id EA3F86B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 13:45:20 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so103056403igb.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 10:45:20 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id lg1si3282713icc.64.2015.07.01.10.45.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 10:45:20 -0700 (PDT)
Received: by iecuq6 with SMTP id uq6so39778567iec.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 10:45:20 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Make the function set_recommended_min_free_kbytes have a return type of void
Date: Wed,  1 Jul 2015 13:45:15 -0400
Message-Id: <1435772715-9534-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This makes the function set_recommended_min_free_kbytes have a
return type of void now due to this particular function never
needing to signal it's call if it fails due to this function
always completing successfully without issue.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/huge_memory.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c107094..914a72a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -104,7 +104,7 @@ static struct khugepaged_scan khugepaged_scan = {
 };
 
 
-static int set_recommended_min_free_kbytes(void)
+static void set_recommended_min_free_kbytes(void)
 {
 	struct zone *zone;
 	int nr_zones = 0;
@@ -139,7 +139,6 @@ static int set_recommended_min_free_kbytes(void)
 		min_free_kbytes = recommended_min;
 	}
 	setup_per_zone_wmarks();
-	return 0;
 }
 
 static int start_stop_khugepaged(void)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
