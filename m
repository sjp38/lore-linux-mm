Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9852E6B0261
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:33:09 -0500 (EST)
Received: by igl9 with SMTP id 9so90041064igl.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:33:09 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id k66si2808079iof.74.2015.11.11.20.32.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:32:50 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 03/17] arch: uapi: asm: mman.h: Let MADV_FREE have same value for all architectures
Date: Thu, 12 Nov 2015 13:32:59 +0900
Message-Id: <1447302793-5376-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1447302793-5376-1-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Chen Gang <gang.chen.5i5j@gmail.com>, "rth@twiddle.net" <rth@twiddle.net>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "mattst88@gmail.com" <mattst88@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, "jejb@parisc-linux.org" <jejb@parisc-linux.org>, "deller@gmx.de" <deller@gmx.de>, "chris@zankel.net" <chris@zankel.net>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, roland@kernel.org, darrick.wong@oracle.com, davem@davemloft.net, Minchan Kim <minchan@kernel.org>

From: Chen Gang <gang.chen.5i5j@gmail.com>

For uapi, need try to let all macros have same value, and MADV_FREE is
added into main branch recently, so need redefine MADV_FREE for it.

At present, '8' can be shared with all architectures, so redefine it to
'8'.

Cc: rth@twiddle.net <rth@twiddle.net>,
Cc: ink@jurassic.park.msu.ru <ink@jurassic.park.msu.ru>
Cc: mattst88@gmail.com <mattst88@gmail.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: jejb@parisc-linux.org <jejb@parisc-linux.org>
Cc: deller@gmx.de <deller@gmx.de>
Cc: chris@zankel.net <chris@zankel.net>
Cc: jcmvbkbc@gmail.com <jcmvbkbc@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org
Cc: linux-api@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: roland@kernel.org
Cc: darrick.wong@oracle.com
Cc: davem@davemloft.net
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 arch/alpha/include/uapi/asm/mman.h     | 2 +-
 arch/mips/include/uapi/asm/mman.h      | 2 +-
 arch/parisc/include/uapi/asm/mman.h    | 2 +-
 arch/xtensa/include/uapi/asm/mman.h    | 2 +-
 include/uapi/asm-generic/mman-common.h | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 836fbd44f65b..0b8a5de7aee3 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -44,9 +44,9 @@
 #define MADV_WILLNEED	3		/* will need these pages */
 #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
 #define MADV_DONTNEED	6		/* don't need these pages */
-#define MADV_FREE	7		/* free pages only if memory pressure */
 
 /* common/generic parameters */
+#define MADV_FREE	8		/* free pages only if memory pressure */
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 106e741aa7ee..d247f5457944 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -67,9 +67,9 @@
 #define MADV_SEQUENTIAL 2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
-#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
+#define MADV_FREE	8		/* free pages only if memory pressure */
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 6cb8db76fd4e..700d83fd9352 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -40,9 +40,9 @@
 #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
 #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
 #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
-#define MADV_FREE	8		/* free pages only if memory pressure */
 
 /* common/generic parameters */
+#define MADV_FREE	8		/* free pages only if memory pressure */
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 1b19f25bc567..77eaca434071 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -80,9 +80,9 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
-#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
+#define MADV_FREE	8		/* free pages only if memory pressure */
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 7a94102b7a02..869595947873 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -34,9 +34,9 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
-#define MADV_FREE	5		/* free pages only if memory pressure */
 
 /* common parameters: try to keep these consistent across architectures */
+#define MADV_FREE	8		/* free pages only if memory pressure */
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
