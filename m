Message-Id: <200405222205.i4MM5kr12722@mail.osdl.org>
Subject: [patch 18/57] numa api: Add i386 support
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:05:11 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

Add NUMA API system calls for i386


---

 25-akpm/arch/i386/kernel/entry.S |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -puN arch/i386/kernel/entry.S~numa-api-i386 arch/i386/kernel/entry.S
--- 25/arch/i386/kernel/entry.S~numa-api-i386	2004-05-22 14:56:24.374386056 -0700
+++ 25-akpm/arch/i386/kernel/entry.S	2004-05-22 14:56:24.377385600 -0700
@@ -876,9 +876,9 @@ ENTRY(sys_call_table)
 	.long sys_utimes
  	.long sys_fadvise64_64
 	.long sys_ni_syscall	/* sys_vserver */
-	.long sys_ni_syscall	/* sys_mbind */
-	.long sys_ni_syscall	/* 275 sys_get_mempolicy */
-	.long sys_ni_syscall	/* sys_set_mempolicy */
+	.long sys_mbind
+	.long sys_get_mempolicy
+	.long sys_set_mempolicy
 	.long sys_mq_open
 	.long sys_mq_unlink
 	.long sys_mq_timedsend

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
