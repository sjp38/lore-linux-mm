Message-Id: <200405222206.i4MM6Jr12768@mail.osdl.org>
Subject: [patch 19/57] numa api: Add IA64 support
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:05:42 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

Add NUMA API system calls on IA64 and one bug fix required for it.


---

 25-akpm/arch/ia64/kernel/entry.S  |    6 +++---
 25-akpm/include/asm-ia64/unistd.h |    6 +++---
 arch/ia64/kernel/acpi.c           |    0 
 3 files changed, 6 insertions(+), 6 deletions(-)

diff -puN arch/ia64/kernel/acpi.c~numa-api-ia64 arch/ia64/kernel/acpi.c
diff -puN arch/ia64/kernel/entry.S~numa-api-ia64 arch/ia64/kernel/entry.S
--- 25/arch/ia64/kernel/entry.S~numa-api-ia64	2004-05-22 14:56:24.498367208 -0700
+++ 25-akpm/arch/ia64/kernel/entry.S	2004-05-22 14:56:24.504366296 -0700
@@ -1501,9 +1501,9 @@ sys_call_table:
 	data8 sys_clock_nanosleep
 	data8 sys_fstatfs64
 	data8 sys_statfs64
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall			// 1260
-	data8 sys_ni_syscall
+	data8 sys_mbind
+	data8 sys_get_mempolicy			// 1260
+	data8 sys_set_mempolicy
 	data8 sys_mq_open
 	data8 sys_mq_unlink
 	data8 sys_mq_timedsend
diff -puN include/asm-ia64/unistd.h~numa-api-ia64 include/asm-ia64/unistd.h
--- 25/include/asm-ia64/unistd.h~numa-api-ia64	2004-05-22 14:56:24.500366904 -0700
+++ 25-akpm/include/asm-ia64/unistd.h	2004-05-22 14:56:24.504366296 -0700
@@ -248,9 +248,9 @@
 #define __NR_clock_nanosleep		1256
 #define __NR_fstatfs64			1257
 #define __NR_statfs64			1258
-#define __NR_reserved1			1259	/* reserved for NUMA interface */
-#define __NR_reserved2			1260	/* reserved for NUMA interface */
-#define __NR_reserved3			1261	/* reserved for NUMA interface */
+#define __NR_mbind			1259
+#define __NR_get_mempolicy		1260
+#define __NR_set_mempolicy		1261
 #define __NR_mq_open			1262
 #define __NR_mq_unlink			1263
 #define __NR_mq_timedsend		1264

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
