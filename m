Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2DC86B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:09:20 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id f16so4488797qth.20
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:09:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w39si603367qta.19.2018.02.08.11.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 11:09:20 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w18J8q4Z018739
	for <linux-mm@kvack.org>; Thu, 8 Feb 2018 14:09:19 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g0vbggc6j-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Feb 2018 14:09:17 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 8 Feb 2018 19:09:15 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm/swap.c: make functions and their kernel-doc agree (again)
Date: Thu,  8 Feb 2018 21:09:06 +0200
Message-Id: <1518116946-20947-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

There was a conflict between the commit e02a9f048ef7 ("mm/swap.c: make
functions and their kernel-doc agree") and the commit f144c390f905 ("mm:
docs: fix parameter names mismatch") that both tried to fix mismatch
betweeen pagevec_lookup_entries() parameter names and their description.

Since nr_entries is a better name for the parameter, fix the description
again.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/swap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 567a7b96e41d..6d7b8bc58003 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -913,7 +913,7 @@ EXPORT_SYMBOL(__pagevec_lru_add);
  * @pvec:	Where the resulting entries are placed
  * @mapping:	The address_space to search
  * @start:	The starting entry index
- * @nr_pages:	The maximum number of pages
+ * @nr_entries:	The maximum number of pages
  * @indices:	The cache indices corresponding to the entries in @pvec
  *
  * pagevec_lookup_entries() will search for and return a group of up
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
