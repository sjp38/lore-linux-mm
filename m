Message-ID: <43E02A04.1080603@jp.fujitsu.com>
Date: Wed, 01 Feb 2006 12:24:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] remove zone_mem_map [2/4] add page_node()
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>
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
