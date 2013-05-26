Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 3FE536B0072
	for <linux-mm@kvack.org>; Sun, 26 May 2013 01:59:00 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 27 May 2013 02:56:10 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2F9152BB0023
	for <linux-mm@kvack.org>; Sun, 26 May 2013 15:58:54 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4Q5ieGp12714174
	for <linux-mm@kvack.org>; Sun, 26 May 2013 15:44:41 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4Q5wqMw009246
	for <linux-mm@kvack.org>; Sun, 26 May 2013 15:58:53 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 5/6] mm/pageblock: remove get/set_pageblock_flags 
Date: Sun, 26 May 2013 13:58:40 +0800
Message-Id: <1369547921-24264-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
