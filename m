Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7E29428029D
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 00:00:04 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so14378124pac.3
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 21:00:04 -0700 (PDT)
Received: from conuserg009-v.nifty.com (conuserg009.nifty.com. [202.248.44.35])
        by mx.google.com with ESMTPS id qn16si21379006pab.235.2015.07.05.21.00.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 05 Jul 2015 21:00:03 -0700 (PDT)
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH] mm: nommu: fix typos in comment blocks.
Date: Mon,  6 Jul 2015 12:59:32 +0900
Message-Id: <1436155172-21625-1-git-send-email-yamada.masahiro@socionext.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Davidlohr Bueso <dave@stgolabs.net>, Paul Gortmaker <paul.gortmaker@windriver.com>, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Christoph Hellwig <hch@lst.de>, Leon Romanovsky <leon@leon.nu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

continguos -> contiguous

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

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
