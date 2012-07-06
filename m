Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id C91386B0070
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 23:26:05 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 5 Jul 2012 21:26:04 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 65EB03E40054
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 03:25:51 +0000 (WET)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q663PJZW201860
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 21:25:35 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q663P2oQ019451
	for <linux-mm@kvack.org>; Thu, 5 Jul 2012 21:25:03 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/buddy: more comments for skip_free_areas_node()
Date: Fri,  6 Jul 2012 11:24:57 +0800
Message-Id: <1341545097-9933-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xiyou.wangcong@gmail.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

The initial idea comes from Cong Wang. We're running out of memory
while calling function skip_free_areas_node(). So it would be unsafe
to allocate more memory from either stack or heap. The patche adds
more comments to address that.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/page_alloc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..c74f5a9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2737,6 +2737,9 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 /*
  * Determine whether the node should be displayed or not, depending on whether
  * SHOW_MEM_FILTER_NODES was passed to show_free_areas().
+ *
+ * We're running out of memory while calling the function. So don't allocate
+ * more memory from either stack or heap.
  */
 bool skip_free_areas_node(unsigned int flags, int nid)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
