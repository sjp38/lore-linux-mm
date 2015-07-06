Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A771828029D
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 00:01:34 -0400 (EDT)
Received: by pdbdz6 with SMTP id dz6so2494188pdb.0
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 21:01:34 -0700 (PDT)
Received: from conuserg011-v.nifty.com (conuserg011.nifty.com. [202.248.44.37])
        by mx.google.com with ESMTPS id v1si26784050pdi.105.2015.07.05.21.01.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 05 Jul 2015 21:01:33 -0700 (PDT)
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH v2] mm: nommu: fix typos in comment blocks
Date: Mon,  6 Jul 2015 13:01:17 +0900
Message-Id: <1436155277-21769-1-git-send-email-yamada.masahiro@socionext.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Davidlohr Bueso <dave@stgolabs.net>, Paul Gortmaker <paul.gortmaker@windriver.com>, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Christoph Hellwig <hch@lst.de>, Leon Romanovsky <leon@leon.nu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

continguos -> contiguous

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

Changes in v2:
  -  Remove '.' from the end of the subject

 mm/nommu.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 58ea364..0b34f40 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -324,12 +324,12 @@ long vwrite(char *buf, char *addr, unsigned long count)
 }
 
 /*
- *	vmalloc  -  allocate virtually continguos memory
+ *	vmalloc  -  allocate virtually contiguous memory
  *
  *	@size:		allocation size
  *
  *	Allocate enough pages to cover @size from the page level
- *	allocator and map them into continguos kernel virtual space.
+ *	allocator and map them into contiguous kernel virtual space.
  *
  *	For tight control over page level allocator and protection flags
  *	use __vmalloc() instead.
@@ -341,12 +341,12 @@ void *vmalloc(unsigned long size)
 EXPORT_SYMBOL(vmalloc);
 
 /*
- *	vzalloc - allocate virtually continguos memory with zero fill
+ *	vzalloc - allocate virtually contiguous memory with zero fill
  *
  *	@size:		allocation size
  *
  *	Allocate enough pages to cover @size from the page level
- *	allocator and map them into continguos kernel virtual space.
+ *	allocator and map them into contiguous kernel virtual space.
  *	The memory allocated is set to zero.
  *
  *	For tight control over page level allocator and protection flags
@@ -420,7 +420,7 @@ void *vmalloc_exec(unsigned long size)
  *	@size:		allocation size
  *
  *	Allocate enough 32bit PA addressable pages to cover @size from the
- *	page level allocator and map them into continguos kernel virtual space.
+ *	page level allocator and map them into contiguous kernel virtual space.
  */
 void *vmalloc_32(unsigned long size)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
