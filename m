Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D7B466B005C
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 16:59:10 -0500 (EST)
Received: by ewy6 with SMTP id 6so35614ewy.14
        for <linux-mm@kvack.org>; Thu, 29 Jan 2009 13:59:08 -0800 (PST)
From: Andrea Righi <righi.andrea@gmail.com>
Subject: [PATCH -mmotm] mm: unify some pmd_*() functions fix for m68k sun3
Date: Thu, 29 Jan 2009 22:58:17 +0100
Message-Id: <1233266297-12995-1-git-send-email-righi.andrea@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Andrea Righi <righi.andrea@gmail.com>
List-ID: <linux-mm.kvack.org>

sun3_defconfig fails with:

    CC      mm/memory.o
  mm/memory.c: In function 'free_pmd_range':
  mm/memory.c:176: error: implicit declaration of function '__pmd_free_tlb'
  mm/memory.c: In function '__pmd_alloc':
  mm/memory.c:2903: error: implicit declaration of function 'pmd_alloc_one_bug'
  mm/memory.c:2903: warning: initialization makes pointer from integer without a cast
  mm/memory.c:2917: error: implicit declaration of function 'pmd_free'
  make[3]: *** [mm/memory.o] Error 1

Add the missing include.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 include/asm-m68k/sun3_pgalloc.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/asm-m68k/sun3_pgalloc.h b/include/asm-m68k/sun3_pgalloc.h
index 0fe28fc..399d280 100644
--- a/include/asm-m68k/sun3_pgalloc.h
+++ b/include/asm-m68k/sun3_pgalloc.h
@@ -11,6 +11,7 @@
 #define _SUN3_PGALLOC_H
 
 #include <asm/tlb.h>
+#include <asm-generic/pgtable-nopmd.h>
 
 /* FIXME - when we get this compiling */
 /* erm, now that it's compiling, what do we do with it? */
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
