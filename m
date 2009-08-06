Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 563C56B005C
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 06:49:30 -0400 (EDT)
Received: by yxe14 with SMTP id 14so906125yxe.12
        for <linux-mm@kvack.org>; Thu, 06 Aug 2009 03:49:36 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 6 Aug 2009 18:49:35 +0800
Message-ID: <dc46d49c0908060349u67dccc12g8c6736bf4cfedf0f@mail.gmail.com>
Subject: =?UTF-8?B?W1BBVENIXSBtdiBjbGVhciBub2RlX2xvYWRbXSB0byBfX2J1aWxkX2FsbF96b25lbGlzdA==?=
	=?UTF-8?B?cygp4oCP?=
From: Bob Liu <yjfpb04@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 If node_load[] is cleared everytime build_zonelists() is called,node_load[]
 will have no help to find the next node that should appear in the given node's
 fallback list.
 Signed-off-by: Bob Liu <bo-liu@hotmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d052abb..72f7345 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2544,7 +2544,6 @@ static void build_zonelists(pg_data_t *pgdat)
 	prev_node = local_node;
 	nodes_clear(used_mask);

-	memset(node_load, 0, sizeof(node_load));
 	memset(node_order, 0, sizeof(node_order));
 	j = 0;

@@ -2653,6 +2652,7 @@ static int __build_all_zonelists(void *dummy)
 {
 	int nid;

+	memset(node_load, 0, sizeof(node_load));
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
