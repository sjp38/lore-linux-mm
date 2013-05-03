Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id BAE0E6B02C1
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:03:01 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:03:01 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 594EA19D803E
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:01:09 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301AJk098430
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:13 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301Aup006931
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:10 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 02/31] rbtree: add rbtree_postorder_for_each_entry_safe() helper.
Date: Thu,  2 May 2013 17:00:34 -0700
Message-Id: <1367539263-19999-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/rbtree.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 2879e96..1b239ca 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -85,4 +85,12 @@ static inline void rb_link_node(struct rb_node * node, struct rb_node * parent,
 	*rb_link = node;
 }
 
+#define rbtree_postorder_for_each_entry_safe(pos, n, root, field) \
+	for (pos = rb_entry(rb_first_postorder(root), typeof(*pos), field),\
+	      n = rb_entry(rb_next_postorder(&pos->field), \
+		      typeof(*pos), field); \
+	     &pos->field; \
+	     pos = n, \
+	      n = rb_entry(rb_next_postorder(&pos->field), typeof(*pos), field))
+
 #endif	/* _LINUX_RBTREE_H */
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
