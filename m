Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 93EEA6B0006
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:57 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 15:44:55 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2D945C90028
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:54 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKirkR278038
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:53 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKirEJ000678
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 17:44:53 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 05/24] rbtree: add rbtree_postorder_for_each_entry_safe() helper.
Date: Thu, 28 Feb 2013 12:44:13 -0800
Message-Id: <1362084272-11282-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <20130228024112.GA24970@negative>
 <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/rbtree.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 2879e96..8ff52b2 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -85,4 +85,11 @@ static inline void rb_link_node(struct rb_node * node, struct rb_node * parent,
 	*rb_link = node;
 }
 
+#define rbtree_postorder_for_each_entry_safe(pos, n, root, field)		\
+	for (pos = rb_entry(rb_first_postorder(root), typeof(*pos), field),	\
+	      n = rb_entry(rb_next_postorder(&pos->field), typeof(*pos), field);	\
+	     &pos->field;							\
+	     pos = n,								\
+	      n = rb_entry(rb_next_postorder(&pos->field), typeof(*pos), field))
+
 #endif	/* _LINUX_RBTREE_H */
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
