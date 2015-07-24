Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 84EEF6B0259
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 17:29:03 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so22089311qkd.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:29:03 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id w195si11689406qha.60.2015.07.24.14.28.48
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 14:28:49 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V5 7/7] mips: Add entry for new mlock2 syscall
Date: Fri, 24 Jul 2015 17:28:45 -0400
Message-Id: <1437773325-8623-8-git-send-email-emunson@akamai.com>
In-Reply-To: <1437773325-8623-1-git-send-email-emunson@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A previous commit introduced the new mlock2 syscall, add entries for the
MIPS architecture.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 arch/mips/include/uapi/asm/unistd.h | 15 +++++++++------
 arch/mips/kernel/scall32-o32.S      |  1 +
 arch/mips/kernel/scall64-64.S       |  1 +
 arch/mips/kernel/scall64-n32.S      |  1 +
 arch/mips/kernel/scall64-o32.S      |  1 +
 5 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/arch/mips/include/uapi/asm/unistd.h b/arch/mips/include/uapi/asm/unistd.h
index c03088f..d0bdfaa 100644
--- a/arch/mips/include/uapi/asm/unistd.h
+++ b/arch/mips/include/uapi/asm/unistd.h
@@ -377,16 +377,17 @@
 #define __NR_memfd_create		(__NR_Linux + 354)
 #define __NR_bpf			(__NR_Linux + 355)
 #define __NR_execveat			(__NR_Linux + 356)
+#define __NR_mlock2			(__NR_Linux + 357)
 
 /*
  * Offset of the last Linux o32 flavoured syscall
  */
-#define __NR_Linux_syscalls		356
+#define __NR_Linux_syscalls		357
 
 #endif /* _MIPS_SIM == _MIPS_SIM_ABI32 */
 
 #define __NR_O32_Linux			4000
-#define __NR_O32_Linux_syscalls		356
+#define __NR_O32_Linux_syscalls		357
 
 #if _MIPS_SIM == _MIPS_SIM_ABI64
 
@@ -711,16 +712,17 @@
 #define __NR_memfd_create		(__NR_Linux + 314)
 #define __NR_bpf			(__NR_Linux + 315)
 #define __NR_execveat			(__NR_Linux + 316)
+#define __NR_mlock2			(__NR_Linux + 317)
 
 /*
  * Offset of the last Linux 64-bit flavoured syscall
  */
-#define __NR_Linux_syscalls		316
+#define __NR_Linux_syscalls		317
 
 #endif /* _MIPS_SIM == _MIPS_SIM_ABI64 */
 
 #define __NR_64_Linux			5000
-#define __NR_64_Linux_syscalls		316
+#define __NR_64_Linux_syscalls		317
 
 #if _MIPS_SIM == _MIPS_SIM_NABI32
 
@@ -1049,15 +1051,16 @@
 #define __NR_memfd_create		(__NR_Linux + 318)
 #define __NR_bpf			(__NR_Linux + 319)
 #define __NR_execveat			(__NR_Linux + 320)
+#define __NR_mlock2			(__NR_Linux + 321)
 
 /*
  * Offset of the last N32 flavoured syscall
  */
-#define __NR_Linux_syscalls		320
+#define __NR_Linux_syscalls		321
 
 #endif /* _MIPS_SIM == _MIPS_SIM_NABI32 */
 
 #define __NR_N32_Linux			6000
-#define __NR_N32_Linux_syscalls		320
+#define __NR_N32_Linux_syscalls		321
 
 #endif /* _UAPI_ASM_UNISTD_H */
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-o32.S
index 4cc1350..b0b377a 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -599,3 +599,4 @@ EXPORT(sys_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf				/* 4355 */
 	PTR	sys_execveat
+	PTR	sys_mlock2
diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64-64.S
index ad4d4463..97aaf51 100644
--- a/arch/mips/kernel/scall64-64.S
+++ b/arch/mips/kernel/scall64-64.S
@@ -436,4 +436,5 @@ EXPORT(sys_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf				/* 5315 */
 	PTR	sys_execveat
+	PTR	sys_mlock2
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall64-n32.S
index 446cc65..e36f21e 100644
--- a/arch/mips/kernel/scall64-n32.S
+++ b/arch/mips/kernel/scall64-n32.S
@@ -429,4 +429,5 @@ EXPORT(sysn32_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf
 	PTR	compat_sys_execveat		/* 6320 */
+	PTR	sys_mlock2
 	.size	sysn32_call_table,.-sysn32_call_table
diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall64-o32.S
index f543ff4..7a8b2df 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -584,4 +584,5 @@ EXPORT(sys32_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf				/* 4355 */
 	PTR	compat_sys_execveat
+	PTR	sys_mlock2
 	.size	sys32_call_table,.-sys32_call_table
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
