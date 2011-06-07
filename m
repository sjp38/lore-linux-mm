Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B7C806B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:05:15 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57CxJmb032055
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 22:59:19 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D4M2V757868
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:04:22 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D5A9L029883
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:05:11 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:28:20 +0530
Message-Id: <20110607125820.28590.19850.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 1/22]  1: X86 specific breakpoint definitions.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>


Provides definitions for the breakpoint instruction and x86 specific
uprobe info structure.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/Kconfig               |    3 +++
 arch/x86/include/asm/uprobes.h |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)
 create mode 100644 arch/x86/include/asm/uprobes.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 30041d8..7c843e2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -243,6 +243,9 @@ config ARCH_CPU_PROBE_RELEASE
 	def_bool y
 	depends on HOTPLUG_CPU
 
+config ARCH_SUPPORTS_UPROBES
+	def_bool y
+
 source "init/Kconfig"
 source "kernel/Kconfig.freezer"
 
diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
new file mode 100644
index 0000000..192ba4a
--- /dev/null
+++ b/arch/x86/include/asm/uprobes.h
@@ -0,0 +1,40 @@
+#ifndef _ASM_UPROBES_H
+#define _ASM_UPROBES_H
+/*
+ * Userspace Probes (UProbes) for x86
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2008-2011
+ * Authors:
+ *	Srikar Dronamraju
+ *	Jim Keniston
+ */
+
+typedef u8 uprobe_opcode_t;
+#define MAX_UINSN_BYTES 16
+#define UPROBES_XOL_SLOT_BYTES	128	/* to keep it cache aligned */
+
+#define UPROBES_BKPT_INSN 0xcc
+#define UPROBES_BKPT_INSN_SIZE 1
+
+#ifdef CONFIG_X86_64
+struct uprobe_arch_info {
+	unsigned long rip_rela_target_address;
+};
+#else
+struct uprobe_arch_info {};
+#endif
+#endif	/* _ASM_UPROBES_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
