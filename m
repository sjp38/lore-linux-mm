Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id BE6C06B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 23:05:33 -0400 (EDT)
Received: by mail-io0-f180.google.com with SMTP id m184so12513267iof.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 20:05:33 -0700 (PDT)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id y10si1008289igl.7.2016.03.22.20.05.32
        for <linux-mm@kvack.org>;
        Tue, 22 Mar 2016 20:05:32 -0700 (PDT)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 4/5] mm/lru: is_file/active_lru can be boolean
Date: Wed, 23 Mar 2016 10:26:08 +0800
Message-Id: <1458699969-3432-5-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1458699969-3432-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, rientjes@google.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, kuleshovmail@gmail.com, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, baiyaowei@cmss.chinamobile.com

This patch makes is_file/active_lru return bool to improve
readability due to these particular functions only using either
one or zero as their return value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/mmzone.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6de02ac3..652d60e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -188,12 +188,12 @@ enum lru_list {
 
 #define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
 
-static inline int is_file_lru(enum lru_list lru)
+static inline bool is_file_lru(enum lru_list lru)
 {
 	return (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE);
 }
 
-static inline int is_active_lru(enum lru_list lru)
+static inline bool is_active_lru(enum lru_list lru)
 {
 	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
 }
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
