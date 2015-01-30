Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E925D828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:52 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so53028521pab.9
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:52 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id oh8si1543211pdb.40.2015.01.30.06.43.50
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/19] m32r: mark PMD folded
Date: Fri, 30 Jan 2015 16:43:15 +0200
Message-Id: <1422629008-13689-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/m32r/include/asm/pgtable-2level.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/m32r/include/asm/pgtable-2level.h b/arch/m32r/include/asm/pgtable-2level.h
index 8fd8ee70266a..421e6ba3a173 100644
--- a/arch/m32r/include/asm/pgtable-2level.h
+++ b/arch/m32r/include/asm/pgtable-2level.h
@@ -13,6 +13,7 @@
  * the M32R is two-level, so we don't really have any
  * PMD directory physically.
  */
+#define __PAGETABLE_PMD_FOLDED
 #define PMD_SHIFT	22
 #define PTRS_PER_PMD	1
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
