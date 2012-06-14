Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 59CF26B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 02:54:04 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 14 Jun 2012 00:54:03 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 4D2AC1FF001D
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 06:54:00 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5E6s0BX195436
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 00:54:00 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5E6rxmp019792
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 00:54:00 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/buddy: make skip_free_areas_node static
Date: Thu, 14 Jun 2012 14:53:56 +0800
Message-Id: <1339656837-28941-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Currently, function skip_free_areas_node() seems to be used only
by page allocator, so make it into static one.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 include/linux/mm.h |    1 -
 mm/page_alloc.c    |    2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..f660ed7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -871,7 +871,6 @@ extern void pagefault_out_of_memory(void);
 #define SHOW_MEM_FILTER_NODES	(0x0001u)	/* filter disallowed nodes */
 
 extern void show_free_areas(unsigned int flags);
-extern bool skip_free_areas_node(unsigned int flags, int nid);
 
 int shmem_zero_setup(struct vm_area_struct *);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7892f84..3d8d9e7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2738,7 +2738,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
  * Determine whether the node should be displayed or not, depending on whether
  * SHOW_MEM_FILTER_NODES was passed to show_free_areas().
  */
-bool skip_free_areas_node(unsigned int flags, int nid)
+static bool skip_free_areas_node(unsigned int flags, int nid)
 {
 	bool ret = false;
 	unsigned int cpuset_mems_cookie;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
