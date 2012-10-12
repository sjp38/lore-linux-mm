Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 158246B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 04:23:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 29DFA3EE0BD
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 17:23:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D93ED45DEBB
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 17:23:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7269545DEC0
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 17:23:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66BD11DB8045
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 17:23:14 +0900 (JST)
Received: from g01jpexchyt24.g01.fujitsu.local (g01jpexchyt24.g01.fujitsu.local [10.128.193.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE10C1DB804A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 17:23:13 +0900 (JST)
Message-ID: <5077D353.3010708@jp.fujitsu.com>
Date: Fri, 12 Oct 2012 17:22:43 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] mm: cleanup register_node()
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com

register_node() is defined as extern in include/linux/node.h. But the function
is only called from register_one_node() in driver/base/node.c.

So the patch defines register_node() as static.

CC: David Rientjes <rientjes@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 drivers/base/node.c  |    2 +-
 include/linux/node.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

Index: linux-3.6/drivers/base/node.c
===================================================================
--- linux-3.6.orig/drivers/base/node.c	2012-10-12 16:35:51.000000000 +0900
+++ linux-3.6/drivers/base/node.c	2012-10-12 16:52:25.294207322 +0900
@@ -259,7 +259,7 @@ static inline void hugetlb_unregister_no
  *
  * Initialize and register the node device.
  */
-int register_node(struct node *node, int num, struct node *parent)
+static int register_node(struct node *node, int num, struct node *parent)
 {
 	int error;
 
Index: linux-3.6/include/linux/node.h
===================================================================
--- linux-3.6.orig/include/linux/node.h	2012-10-01 08:47:46.000000000 +0900
+++ linux-3.6/include/linux/node.h	2012-10-12 16:52:55.215210433 +0900
@@ -30,7 +30,6 @@ struct memory_block;
 extern struct node node_devices[];
 typedef  void (*node_registration_func_t)(struct node *);
 
-extern int register_node(struct node *, int, struct node *);
 extern void unregister_node(struct node *node);
 #ifdef CONFIG_NUMA
 extern int register_one_node(int nid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
