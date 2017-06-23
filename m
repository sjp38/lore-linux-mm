Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5916B02FD
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:08:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so12182179wrc.8
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:08:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y123si3778042wmd.16.2017.06.23.05.08.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 05:08:56 -0700 (PDT)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH  v2] mm: Remove ancient/ambiguous comment
Date: Fri, 23 Jun 2017 15:08:52 +0300
Message-Id: <1498219732-21923-1-git-send-email-nborisov@suse.com>
In-Reply-To: <20170623114617.GO5308@dhcp22.suse.cz>
References: <20170623114617.GO5308@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, mhocko@suse.com, Nikolay Borisov <nborisov@suse.com>

Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---
 include/linux/mmzone.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ef6a13b7bd3e..d260eb30e4ce 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -587,12 +587,9 @@ extern struct page *mem_map;
 #endif
 
 /*
- * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
- * (mostly NUMA machines?) to denote a higher-level memory zone than the
- * zone denotes.
- *
  * On NUMA machines, each NUMA node would have a pg_data_t to describe
- * it's memory layout.
+ * it's memory layout. On UMA machines there is a single pglist_data which
+ * describes the whole memory.
  *
  * Memory statistics and page replacement data structures are maintained on a
  * per-zone basis.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
