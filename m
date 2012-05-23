Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A4C8B6B00E7
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:29:49 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: Text/Plain; charset=us-ascii
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M4G00DK3SU2Z880@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 23 May 2012 08:30:02 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4G00IQVSTNCE@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 23 May 2012 08:29:47 +0100 (BST)
Date: Wed, 23 May 2012 09:27:21 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] vmevent: add arm support
Message-id: <201205230927.21766.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, linux-mm@kvack.org

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] vmevent: add arm support

Tested on ARM EXYNOS4210 (Universal C210 board).

Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/include/asm/unistd.h        |    1 +
 arch/arm/kernel/calls.S              |    1 +
 tools/testing/vmevent/vmevent-test.c |    3 +++
 3 files changed, 5 insertions(+)

Index: b/arch/arm/include/asm/unistd.h
===================================================================
--- a/arch/arm/include/asm/unistd.h	2012-05-22 15:17:15.590826904 +0200
+++ b/arch/arm/include/asm/unistd.h	2012-05-22 15:17:43.990826872 +0200
@@ -404,6 +404,7 @@
 #define __NR_setns			(__NR_SYSCALL_BASE+375)
 #define __NR_process_vm_readv		(__NR_SYSCALL_BASE+376)
 #define __NR_process_vm_writev		(__NR_SYSCALL_BASE+377)
+#define __NR_vmevent_fd		(__NR_SYSCALL_BASE+378)
 
 /*
  * The following SWIs are ARM private.
Index: b/arch/arm/kernel/calls.S
===================================================================
--- a/arch/arm/kernel/calls.S	2012-05-22 15:16:31.646826898 +0200
+++ b/arch/arm/kernel/calls.S	2012-05-22 15:17:02.850825441 +0200
@@ -387,6 +387,7 @@
 /* 375 */	CALL(sys_setns)
 		CALL(sys_process_vm_readv)
 		CALL(sys_process_vm_writev)
+		CALL(sys_vmevent_fd)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
Index: b/tools/testing/vmevent/vmevent-test.c
===================================================================
--- a/tools/testing/vmevent/vmevent-test.c	2012-05-22 15:18:46.702826642 +0200
+++ b/tools/testing/vmevent/vmevent-test.c	2012-05-22 15:19:21.302826872 +0200
@@ -3,6 +3,9 @@
 #if defined(__x86_64__)
 #include "../../../arch/x86/include/generated/asm/unistd_64.h"
 #endif
+#if defined(__arm__)
+#include "../../../arch/arm/include/asm/unistd.h"
+#endif
 
 #include <stdint.h>
 #include <stdlib.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
