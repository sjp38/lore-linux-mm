Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137d7oN013807 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:39:07 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s10.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137d6Wg002881 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:39:06 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s10.gw.fujitsu.co.jp (s10 [127.0.0.1])
	by s10.gw.fujitsu.co.jp (Postfix) with ESMTP id 450211CC10C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:39:06 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s10.gw.fujitsu.co.jp (Postfix) with ESMTP id AB16C1CC101
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:39:05 +0900 (JST)
Received: from [127.0.0.1] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm505.ms.jp.fujitsu.com with ESMTP id k137crvi003305
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:38:54 +0900
Message-ID: <43E308C9.2020702@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:39:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] pearing off zone from physical memory layout [2/10]  add helper
 function page_node()
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

A helper function to access pgdat from pages.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: hogehoge/include/linux/mm.h
===================================================================
--- hogehoge.orig/include/linux/mm.h
+++ hogehoge/include/linux/mm.h
@@ -478,6 +478,12 @@ static inline unsigned long page_to_nid(
  	else
  		return page_zone(page)->zone_pgdat->node_id;
  }
+
+static inline struct pglist_data *page_node(struct page *page)
+{
+	return NODE_DATA(page_to_nid(page));
+}
+
  static inline unsigned long page_to_section(struct page *page)
  {
  	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
