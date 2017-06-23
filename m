Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA666B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:35:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u110so11957046wrb.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:35:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a71si3868851wme.172.2017.06.23.04.35.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 04:35:22 -0700 (PDT)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH] mm: Remove ancient/ambiguous comment
Date: Fri, 23 Jun 2017 14:35:17 +0300
Message-Id: <1498217717-20945-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, mhocko@suse.com, Nikolay Borisov <nborisov@suse.com>

Currently pg_data_t is just a struct which describes a NUMA node memory 
layout. Let's keep the comment simple and remove ambiguity.

Signed-off-by: Nikolay Borisov <nborisov@suse.com>
---
 include/linux/mmzone.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ef6a13b7bd3e..c870c65fb945 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -587,10 +587,6 @@ extern struct page *mem_map;
 #endif
 
 /*
- * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
- * (mostly NUMA machines?) to denote a higher-level memory zone than the
- * zone denotes.
- *
  * On NUMA machines, each NUMA node would have a pg_data_t to describe
  * it's memory layout.
  *
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
