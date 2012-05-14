Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9BDB56B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:28:17 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 14 May 2012 04:28:16 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id E725A1FF001C
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:28:10 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4EASCnJ237280
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:28:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4EASB9t023511
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:28:12 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/buddy: dump PG_compound_lock page flag
Date: Mon, 14 May 2012 18:26:53 +0800
Message-Id: <1336991213-9149-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

The array pageflag_names[] is doing the conversion from page flag
into the corresponding names so that the meaingful string again
the corresponding page flag can be printed. The mechniasm is used
while dumping the specified page frame. However, the array missed
PG_compound_lock. So PG_compound_lock page flag would be printed
as ditigal number instead of meaningful string.

The patch fixes that and print "compound_lock" for PG_compound_lock
page flag.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/page_alloc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1277632..d39f253 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5652,6 +5652,9 @@ static struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_MEMORY_FAILURE
 	{1UL << PG_hwpoison,		"hwpoison"	},
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	{1UL << PG_compound_lock,	"compound_lock"	},
+#endif
 	{-1UL,				NULL		},
 };
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
