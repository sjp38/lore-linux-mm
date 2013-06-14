Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4B0D16B0038
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 03:31:09 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 14 Jun 2013 17:19:54 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 3BD3E357804E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 17:31:02 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5E7GQ4d64290974
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 17:16:26 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5E7V1ZV028031
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 17:31:01 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 5/8] mm/page_alloc: fix blank in show_free_areas
Date: Fri, 14 Jun 2013 15:30:38 +0800
Message-Id: <1371195041-26654-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
index c3edb62..3c5ba4e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3001,12 +3001,12 @@ void show_free_areas(unsigned int filter)
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
