Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EBB4E6B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 09:50:31 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so13069390pac.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:50:31 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id la15si5672344pab.205.2015.12.08.06.50.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 06:50:31 -0800 (PST)
Received: by pfnn128 with SMTP id n128so13223166pfn.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:50:31 -0800 (PST)
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH v2] arch/*/include/uapi/asm/mman.h: correct uniform value of MADV_FREE
Date: Tue,  8 Dec 2015 20:20:22 +0530
Message-Id: <1449586222-4689-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Minchan Kim <minchan@kernel.org>, Chen Gang <gang.chen.5i5j@gmail.com>

commit d53d95838c7d introduced uniform values for all architecture but
missed removing the old value.

As a result we are having build failure with mips defconfig, alpha
defconfig.

Fixes: d53d95838c7d ("arch/*/include/uapi/asm/mman.h: : let MADV_FREE have same value for all architectures")
Cc: Minchan Kim <minchan@kernel.org>
Cc: Chen Gang <gang.chen.5i5j@gmail.com>
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---

v2: combined the patches for different arch in this single patch.

 arch/alpha/include/uapi/asm/mman.h  | 1 -
 arch/mips/include/uapi/asm/mman.h   | 1 -
 arch/parisc/include/uapi/asm/mman.h | 1 -
 arch/xtensa/include/uapi/asm/mman.h | 1 -
 4 files changed, 4 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index ab336c0..fec1947 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -47,7 +47,6 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
-#define MADV_FREE	7		/* free pages only if memory pressure */
 
 /* common/generic parameters */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index b0ebe59..ccdcfcb 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -73,7 +73,6 @@
 #define MADV_SEQUENTIAL 2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
-#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index cf830d4..f3db7d8 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -43,7 +43,6 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
-#define MADV_FREE	8		/* free pages only if memory pressure */
 
 /* common/generic parameters */
 #define MADV_FREE	8		/* free pages only if memory pressure */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index d030594..9e079d4 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -86,7 +86,6 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
-#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
 #define MADV_FREE	8		/* free pages only if memory pressure */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
