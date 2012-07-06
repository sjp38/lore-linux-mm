Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 498236B0062
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 01:53:05 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 5 Jul 2012 23:53:03 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 962841FF0038
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 05:52:50 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q665qJYX244742
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 23:52:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q665q4DG011637
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 23:52:04 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2] mm/buddy: more comments for show_free_areas()
Date: Fri,  6 Jul 2012 13:51:59 +0800
Message-Id: <1341553919-4442-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xiyou.wangcong@gmail.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

The initial idea comes from Cong Wang. We're running out of memory
while calling function show_free_areas(). So it would be unsafe
to allocate more memory from either stack or heap. The patche adds
more comments to address that.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/page_alloc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..280c13b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2762,6 +2762,9 @@ out:
  * memory on each free list with the exception of the first item on the list.
  * Suppresses nodes that are not allowed by current's cpuset if
  * SHOW_MEM_FILTER_NODES is passed.
+ *
+ * We're running out of memory while calling the function. So don't allocate
+ * more memory from either stack or heap.
  */
 void show_free_areas(unsigned int filter)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
