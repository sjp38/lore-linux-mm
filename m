Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 597226B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:20:25 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j4so3200055wrg.15
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:20:25 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id q39si3534431wrb.248.2017.12.14.05.20.23
        for <linux-mm@kvack.org>;
        Thu, 14 Dec 2017 05:20:23 -0800 (PST)
From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH] mm/mmu_context: Remove asm/mmu_context.h include directive
Date: Thu, 14 Dec 2017 14:20:05 +0100
Message-Id: <20171214132005.12704-1-bp@alien8.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>

From: Borislav Petkov <bp@suse.de>

The header linux/mmu_context.h includes it already. Otherwise, you get
warnings like below with some configs.

  In file included from mm/mmu_context.c:11:0:
  ./arch/x86/include/asm/mmu_context.h:129:0: warning: "switch_mm_irqs_off" redefined [enabled by default]
   #define switch_mm_irqs_off switch_mm_irqs_off
   ^
  In file included from mm/mmu_context.c:8:0:
  include/linux/mmu_context.h:15:0: note: this is the location of the previous definition
   # define switch_mm_irqs_off switch_mm
   ^

Signed-off-by: Borislav Petkov <bp@suse.de>
---
 mm/mmu_context.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index 3e612ae748e9..50c556e19383 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -10,8 +10,6 @@
 #include <linux/mmu_context.h>
 #include <linux/export.h>
 
-#include <asm/mmu_context.h>
-
 /*
  * use_mm
  *	Makes the calling kernel thread take on the specified
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
