Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7606B0257
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:52:45 -0500 (EST)
Received: by oies6 with SMTP id s6so79594639oie.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:52:45 -0800 (PST)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id sx2si15187236oeb.21.2015.11.15.22.52.43
        for <linux-mm@kvack.org>;
        Sun, 15 Nov 2015 22:52:44 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 5/7] mm/lru: remove unused is_unevictable_lru function
Date: Mon, 16 Nov 2015 14:51:24 +0800
Message-Id: <1447656686-4851-6-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit a0b8cab3 ("mm: remove lru parameter from __pagevec_lru_add
and remove parts of pagevec API") there's no user of this function anymore,
so remove it.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/mmzone.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e23a9e7..9963846 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -195,11 +195,6 @@ static inline int is_active_lru(enum lru_list lru)
 	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
 }
 
-static inline int is_unevictable_lru(enum lru_list lru)
-{
-	return (lru == LRU_UNEVICTABLE);
-}
-
 struct zone_reclaim_stat {
 	/*
 	 * The pageout code in vmscan.c keeps track of how many of the
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
