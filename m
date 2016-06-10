Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 28D646B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 14:06:56 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e5so3149887ith.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 11:06:56 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id u191si196248itu.90.2016.06.10.11.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 11:06:55 -0700 (PDT)
Subject: [PATCH] mm: add missing kernel-doc in mm/memory.c::do_set_pte()
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <575B01BD.9020809@infradead.org>
Date: Fri, 10 Jun 2016 11:06:53 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warning in mm/memory.c:

..//mm/memory.c:2881: warning: No description found for parameter 'old'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 mm/memory.c |    1 +
 1 file changed, 1 insertion(+)

--- lnx-47-rc2.orig/mm/memory.c
+++ lnx-47-rc2/mm/memory.c
@@ -2870,6 +2870,7 @@ static int __do_fault(struct vm_area_str
  * @pte: pointer to target page table entry
  * @write: true, if new entry is writable
  * @anon: true, if it's anonymous page
+ * @old: if true, mark the PTE as old (clear _PAGE_ACCESSED for this entry)
  *
  * Caller must hold page table lock relevant for @pte.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
