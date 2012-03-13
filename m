Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 34B1D6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 05:42:29 -0400 (EDT)
Date: Tue, 13 Mar 2012 02:41:39 -0700
From: tip-bot for Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Message-ID: <tip-900771a483ef28915a48066d7895d8252315607a@git.kernel.org>
Reply-To: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com,
        andi@firstfloor.org, torvalds@linux-foundation.org,
        peterz@infradead.org, hch@infradead.org, ananth@in.ibm.com,
        masami.hiramatsu.pt@hitachi.com, acme@infradead.org,
        rostedt@goodmis.org, jkenisto@linux.vnet.ibm.com,
        srikar@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com,
        linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <20120312092514.5379.36595.sendpatchset@srdronam.in.ibm.com>
References: <20120312092514.5379.36595.sendpatchset@srdronam.in.ibm.com>
Subject: [tip:perf/uprobes] uprobes/core: Make macro names consistent
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mingo@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, rostedt@goodmis.org, jkenisto@linux.vnet.ibm.com, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, hpa@zytor.com, linux-kernel@vger.kernel.org, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, mingo@elte.hu

Commit-ID:  900771a483ef28915a48066d7895d8252315607a
Gitweb:     http://git.kernel.org/tip/900771a483ef28915a48066d7895d8252315607a
Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
AuthorDate: Mon, 12 Mar 2012 14:55:14 +0530
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Tue, 13 Mar 2012 06:22:20 +0100

uprobes/core: Make macro names consistent

Rename macros that refer to individual uprobe to start with
UPROBE_ instead of UPROBES_.

This is pure cleanup, no functional change intended.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Jim Keniston <jkenisto@linux.vnet.ibm.com>
Cc: Linux-mm <linux-mm@kvack.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Link: http://lkml.kernel.org/r/20120312092514.5379.36595.sendpatchset@srdronam.in.ibm.com
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/include/asm/uprobes.h |    6 +++---
 arch/x86/kernel/uprobes.c      |   18 +++++++++---------
 include/linux/uprobes.h        |    4 ++--
 kernel/events/uprobes.c        |   18 +++++++++---------
 4 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index f7ce310..5c399e4 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -26,10 +26,10 @@
 typedef u8 uprobe_opcode_t;
 
 #define MAX_UINSN_BYTES			  16
-#define UPROBES_XOL_SLOT_BYTES		 128	/* to keep it cache aligned */
+#define UPROBE_XOL_SLOT_BYTES		 128	/* to keep it cache aligned */
 
-#define UPROBES_BKPT_INSN		0xcc
-#define UPROBES_BKPT_INSN_SIZE		   1
+#define UPROBE_BKPT_INSN		0xcc
+#define UPROBE_BKPT_INSN_SIZE		   1
 
 struct arch_uprobe {
 	u16				fixups;
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index 04dfcef..6dfa89e 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -31,14 +31,14 @@
 /* Post-execution fixups. */
 
 /* No fixup needed */
-#define UPROBES_FIX_NONE	0x0
+#define UPROBE_FIX_NONE	0x0
 /* Adjust IP back to vicinity of actual insn */
-#define UPROBES_FIX_IP		0x1
+#define UPROBE_FIX_IP		0x1
 /* Adjust the return address of a call insn */
-#define UPROBES_FIX_CALL	0x2
+#define UPROBE_FIX_CALL	0x2
 
-#define UPROBES_FIX_RIP_AX	0x8000
-#define UPROBES_FIX_RIP_CX	0x4000
+#define UPROBE_FIX_RIP_AX	0x8000
+#define UPROBE_FIX_RIP_CX	0x4000
 
 /* Adaptations for mhiramat x86 decoder v14. */
 #define OPCODE1(insn)		((insn)->opcode.bytes[0])
@@ -269,9 +269,9 @@ static void prepare_fixups(struct arch_uprobe *auprobe, struct insn *insn)
 		break;
 	}
 	if (fix_ip)
-		auprobe->fixups |= UPROBES_FIX_IP;
+		auprobe->fixups |= UPROBE_FIX_IP;
 	if (fix_call)
-		auprobe->fixups |= UPROBES_FIX_CALL;
+		auprobe->fixups |= UPROBE_FIX_CALL;
 }
 
 #ifdef CONFIG_X86_64
@@ -341,12 +341,12 @@ static void handle_riprel_insn(struct mm_struct *mm, struct arch_uprobe *auprobe
 		 * is NOT the register operand, so we use %rcx (register
 		 * #1) for the scratch register.
 		 */
-		auprobe->fixups = UPROBES_FIX_RIP_CX;
+		auprobe->fixups = UPROBE_FIX_RIP_CX;
 		/* Change modrm from 00 000 101 to 00 000 001. */
 		*cursor = 0x1;
 	} else {
 		/* Use %rax (register #0) for the scratch register. */
-		auprobe->fixups = UPROBES_FIX_RIP_AX;
+		auprobe->fixups = UPROBE_FIX_RIP_AX;
 		/* Change modrm from 00 xxx 101 to 00 xxx 000 */
 		*cursor = (reg << 3);
 	}
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index f85797e..838fb31 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -35,10 +35,10 @@ struct vm_area_struct;
 /* flags that denote/change uprobes behaviour */
 
 /* Have a copy of original instruction */
-#define UPROBES_COPY_INSN	0x1
+#define UPROBE_COPY_INSN	0x1
 
 /* Dont run handlers when first register/ last unregister in progress*/
-#define UPROBES_RUN_HANDLER	0x2
+#define UPROBE_RUN_HANDLER	0x2
 
 struct uprobe_consumer {
 	int (*handler)(struct uprobe_consumer *self, struct pt_regs *regs);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 5ce32e3..0d36bf3 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -177,7 +177,7 @@ out:
  */
 bool __weak is_bkpt_insn(uprobe_opcode_t *insn)
 {
-	return *insn == UPROBES_BKPT_INSN;
+	return *insn == UPROBE_BKPT_INSN;
 }
 
 /*
@@ -259,8 +259,8 @@ static int write_opcode(struct mm_struct *mm, struct arch_uprobe *auprobe,
 
 	/* poke the new insn in, ASSUMES we don't cross page boundary */
 	vaddr &= ~PAGE_MASK;
-	BUG_ON(vaddr + UPROBES_BKPT_INSN_SIZE > PAGE_SIZE);
-	memcpy(vaddr_new + vaddr, &opcode, UPROBES_BKPT_INSN_SIZE);
+	BUG_ON(vaddr + UPROBE_BKPT_INSN_SIZE > PAGE_SIZE);
+	memcpy(vaddr_new + vaddr, &opcode, UPROBE_BKPT_INSN_SIZE);
 
 	kunmap_atomic(vaddr_new);
 	kunmap_atomic(vaddr_old);
@@ -308,7 +308,7 @@ static int read_opcode(struct mm_struct *mm, unsigned long vaddr, uprobe_opcode_
 	lock_page(page);
 	vaddr_new = kmap_atomic(page);
 	vaddr &= ~PAGE_MASK;
-	memcpy(opcode, vaddr_new + vaddr, UPROBES_BKPT_INSN_SIZE);
+	memcpy(opcode, vaddr_new + vaddr, UPROBE_BKPT_INSN_SIZE);
 	kunmap_atomic(vaddr_new);
 	unlock_page(page);
 
@@ -352,7 +352,7 @@ int __weak set_bkpt(struct mm_struct *mm, struct arch_uprobe *auprobe, unsigned
 	if (result)
 		return result;
 
-	return write_opcode(mm, auprobe, vaddr, UPROBES_BKPT_INSN);
+	return write_opcode(mm, auprobe, vaddr, UPROBE_BKPT_INSN);
 }
 
 /**
@@ -635,7 +635,7 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 
 	addr = (unsigned long)vaddr;
 
-	if (!(uprobe->flags & UPROBES_COPY_INSN)) {
+	if (!(uprobe->flags & UPROBE_COPY_INSN)) {
 		ret = copy_insn(uprobe, vma, addr);
 		if (ret)
 			return ret;
@@ -647,7 +647,7 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 		if (ret)
 			return ret;
 
-		uprobe->flags |= UPROBES_COPY_INSN;
+		uprobe->flags |= UPROBE_COPY_INSN;
 	}
 	ret = set_bkpt(mm, &uprobe->arch, addr);
 
@@ -857,7 +857,7 @@ int uprobe_register(struct inode *inode, loff_t offset, struct uprobe_consumer *
 			uprobe->consumers = NULL;
 			__uprobe_unregister(uprobe);
 		} else {
-			uprobe->flags |= UPROBES_RUN_HANDLER;
+			uprobe->flags |= UPROBE_RUN_HANDLER;
 		}
 	}
 
@@ -889,7 +889,7 @@ void uprobe_unregister(struct inode *inode, loff_t offset, struct uprobe_consume
 	if (consumer_del(uprobe, consumer)) {
 		if (!uprobe->consumers) {
 			__uprobe_unregister(uprobe);
-			uprobe->flags &= ~UPROBES_RUN_HANDLER;
+			uprobe->flags &= ~UPROBE_RUN_HANDLER;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
