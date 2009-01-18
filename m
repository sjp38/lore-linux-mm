Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D50D06B00A3
	for <linux-mm@kvack.org>; Sun, 18 Jan 2009 17:36:29 -0500 (EST)
Received: by ewy9 with SMTP id 9so350502ewy.14
        for <linux-mm@kvack.org>; Sun, 18 Jan 2009 14:36:27 -0800 (PST)
Message-ID: <4973AEEC.70504@gmail.com>
Date: Sun, 18 Jan 2009 23:36:28 +0100
From: Roel Kluin <roel.kluin@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: get_nid_for_pfn() returns int
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: garyhade@us.ibm.com, Ingo Molnar <mingo@elte.hu>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

get_nid_for_pfn() returns int

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
vi drivers/base/node.c +256
static int get_nid_for_pfn(unsigned long pfn)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 43fa90b..f8f578a 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -303,7 +303,7 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
 	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
-		unsigned int nid;
+		int nid;
 
 		nid = get_nid_for_pfn(pfn);
 		if (nid < 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
