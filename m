Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 40F0B6B00DE
	for <linux-mm@kvack.org>; Sun, 26 May 2013 19:47:27 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 27 May 2013 05:12:11 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id BC116125804F
	for <linux-mm@kvack.org>; Mon, 27 May 2013 05:19:22 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4QNlGI7065946
	for <linux-mm@kvack.org>; Mon, 27 May 2013 05:17:16 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4QNlLL1024728
	for <linux-mm@kvack.org>; Sun, 26 May 2013 23:47:21 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 2/3] mm/pageblock: remove get/set_pageblock_flags 
Date: Mon, 27 May 2013 07:47:14 +0800
Message-Id: <1369612035-3430-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1369612035-3430-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1369612035-3430-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog: 
 v1 -> v2: 
	* add Michal reviewed-by 

get_pageblock_flags and set_pageblock_flags are not used any 
more, this patch remove them.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/pageblock-flags.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index be655e4..2ee8cd2 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -80,10 +80,4 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
 							PB_migrate_skip)
 #endif /* CONFIG_COMPACTION */
 
-#define get_pageblock_flags(page) \
-			get_pageblock_flags_group(page, 0, PB_migrate_end)
-#define set_pageblock_flags(page, flags) \
-			set_pageblock_flags_group(page, flags,	\
-						  0, PB_migrate_end)
-
 #endif	/* PAGEBLOCK_FLAGS_H */
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
