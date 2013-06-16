Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id F32AA6B0039
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 21:15:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 16 Jun 2013 06:40:39 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A61F7394004E
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 06:45:03 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5G1EwUx30605556
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 06:44:58 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5G1F14L032332
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 11:15:02 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 4/7] mm/page_alloc: fix blank in show_free_areas
Date: Sun, 16 Jun 2013 09:14:47 +0800
Message-Id: <1371345290-19588-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

There is a blank in show_free_areas which lead to dump messages aren't
aligned. This patch remove blank.

Before patch:

[155219.720141] active_anon:50675 inactive_anon:35273 isolated_anon:0
[155219.720141]  active_file:215421 inactive_file:344268 isolated_file:0
[155219.720141]  unevictable:0 dirty:35 writeback:0 unstable:0
[155219.720141]  free:1334870 slab_reclaimable:28833 slab_unreclaimable:5115
[155219.720141]  mapped:25233 shmem:35511 pagetables:1705 bounce:0
[155219.720141]  free_cma:0

After patch:

[   73.913889] active_anon:39578 inactive_anon:32082 isolated_anon:0
[   73.913889] active_file:14621 inactive_file:57993 isolated_file:0
[   73.913889] unevictable:0dirty:263 writeback:0 unstable:0
[   73.913889] free:1865614 slab_reclaimable:3264 slab_unreclaimable:4566
[   73.913889] mapped:21192 shmem:32327 pagetables:1572 bounce:0
[   73.913889] free_cma:0

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18102e1..e6e881a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3004,12 +3004,12 @@ void show_free_areas(unsigned int filter)
 	}
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
-		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
-		" unevictable:%lu"
-		" dirty:%lu writeback:%lu unstable:%lu\n"
-		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free_cma:%lu\n",
+		"active_file:%lu inactive_file:%lu isolated_file:%lu\n"
+		"unevictable:%lu"
+		"dirty:%lu writeback:%lu unstable:%lu\n"
+		"free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
+		"mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+		"free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_ISOLATED_ANON),
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
