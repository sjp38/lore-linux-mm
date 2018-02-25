Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7166B0008
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 14:00:10 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z17so3417723qti.11
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 11:00:10 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b36si7668465qkb.297.2018.02.25.11.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Feb 2018 11:00:09 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1PIsGTV026615
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 14:00:08 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gbnvq9mjp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 14:00:08 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 25 Feb 2018 19:00:06 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] mm/swap: remove @cold parameter description for release_pages
Date: Sun, 25 Feb 2018 20:59:50 +0200
In-Reply-To: <1519585191-10180-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1519585191-10180-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1519585191-10180-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-doc <linux-doc@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The 'cold' parameter was removed from release_pages function by the commit
c6f92f9fbe7db ("mm: remove cold parameter for release_pages").
Update the description to match the code.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/swap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 0f17330dd0e5..3dd518832096 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -707,7 +707,6 @@ void lru_add_drain_all(void)
  * release_pages - batched put_page()
  * @pages: array of pages to release
  * @nr: number of pages
- * @cold: whether the pages are cache cold
  *
  * Decrement the reference count on all the pages in @pages.  If it
  * fell to zero, remove the page from the LRU and free it.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
