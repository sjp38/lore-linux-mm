Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9006B03A7
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:36 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id z13so41863145iof.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:36 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0238.hostedemail.com. [216.40.44.238])
        by mx.google.com with ESMTPS id c8si4675711ioe.168.2017.03.15.19.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:35 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/15] mm: page_alloc: Use the common commenting style
Date: Wed, 15 Mar 2017 19:00:06 -0700
Message-Id: <4573a4c65f069b60292458130b58cda88c009301.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Just neatening

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e417d52b9de9..3e1d377201b8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5222,8 +5222,10 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 		if (zone)
 			setup_zone_pageset(zone);
 #endif
-		/* we have to stop all cpus to guarantee there is no user
-		   of zonelist */
+		/*
+		 * we have to stop all cpus to guarantee
+		 * there is no user of zonelist
+		 */
 		stop_machine(__build_all_zonelists, pgdat, NULL);
 		/* cpuset refresh routine should be here */
 	}
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
