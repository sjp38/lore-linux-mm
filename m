Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE876B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 16:59:03 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so154182eek.27
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 13:59:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f8si20852749eep.225.2013.11.21.13.59.02
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 13:59:02 -0800 (PST)
Date: Thu, 21 Nov 2013 16:43:35 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH] mm/bootmem.c: remove unused 'limit' variable
Message-ID: <20131121164335.066fd6aa@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org


Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
---
 mm/bootmem.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 90bd350..31d303e 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -655,9 +655,7 @@ restart:
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 					unsigned long goal)
 {
-	unsigned long limit = 0;
-
-	return ___alloc_bootmem_nopanic(size, align, goal, limit);
+	return ___alloc_bootmem_nopanic(size, align, goal, 0);
 }
 
 static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
@@ -691,9 +689,7 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
 void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 			      unsigned long goal)
 {
-	unsigned long limit = 0;
-
-	return ___alloc_bootmem(size, align, goal, limit);
+	return ___alloc_bootmem(size, align, goal, 0);
 }
 
 void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
