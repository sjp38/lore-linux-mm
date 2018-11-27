Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB5C6B4A84
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:06:20 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so23709188qkb.23
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 13:06:20 -0800 (PST)
Received: from relay64.bu.edu (relay64.bu.edu. [128.197.228.104])
        by mx.google.com with ESMTPS id r25si3876472qtn.101.2018.11.27.13.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 13:06:19 -0800 (PST)
From: Emre Ates <ates@bu.edu>
Subject: [PATCH] Small typo fix
Date: Tue, 27 Nov 2018 16:04:59 -0500
Message-Id: <20181127210459.11809-1-ates@bu.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, ates@bu.edu

---
 mm/vmstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9c624595e904..cc7d04928c2e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1106,7 +1106,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 					TEXT_FOR_HIGHMEM(xx) xx "_movable",

 const char * const vmstat_text[] = {
-	/* enum zone_stat_item countes */
+	/* enum zone_stat_item counters */
 	"nr_free_pages",
 	"nr_zone_inactive_anon",
 	"nr_zone_active_anon",
--
2.19.1

Signed-off-by: Emre Ates <ates@bu.edu>
