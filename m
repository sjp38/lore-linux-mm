Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id BDF906B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 07:41:58 -0500 (EST)
Received: by wmec201 with SMTP id c201so23628071wme.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:41:58 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id s10si47800183wmf.20.2015.11.19.04.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 04:41:57 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: include linux/pfn.h for PHYS_PFN definition
Date: Thu, 19 Nov 2015 13:41:53 +0100
Message-ID: <5841074.QcbTqgbsZz@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org, Chen Gang <gang.chen.5i5j@gmail.com>, Oleg Nesterov <oleg@redhat.com>

A change to asm-generic/memory_model.h caused a new build error
in some configurations:

mach-clps711x/common.c:39:10: error: implicit declaration of function 'PHYS_PFN'
   .pfn  = __phys_to_pfn(CLPS711X_PHYS_BASE),

This includes the linux/pfn.h header from the same file to avoid the
error.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: bf1c6c9895de ("mm: add PHYS_PFN, use it in __phys_to_pfn()")
---
I was listed as 'Cc' on the original patch, but don't see it in my inbox.

I can queue up the fixed version in the asm-generic tree if you like that,
otherwise please fold this fixup into the patch, or drop it if we want to
avoid the extra #include.

diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/memory_model.h
index c785a79d9385..5148150cc80b 100644
--- a/include/asm-generic/memory_model.h
+++ b/include/asm-generic/memory_model.h
@@ -1,6 +1,8 @@
 #ifndef __ASM_MEMORY_MODEL_H
 #define __ASM_MEMORY_MODEL_H
 
+#include <linux/pfn.h>
+
 #ifndef __ASSEMBLY__
 
 #if defined(CONFIG_FLATMEM)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
