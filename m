Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEB0620026
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:17:15 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 63/96] c/r: define s390-specific checkpoint-restart code
Date: Wed, 17 Mar 2010 12:08:51 -0400
Message-Id: <1268842164-5590-64-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-63-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-52-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-53-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-54-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-55-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-56-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-57-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-58-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-59-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-60-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-61-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-62-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-63-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Dan Smith <danms@us.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

Implement the s390 arch-specific checkpoint/restart helpers.  This
is on top of Oren Laadan's c/r code.

With these, I am able to checkpoint and restart simple programs as per
Oren's patch intro.  While on x86 I never had to freeze a single task
to checkpoint it, on s390 I do need to.  That is a prereq for consistent
snapshots (esp with multiple processes) anyway so I don't see that as
a problem.

Changelog [v20]:
  - [Serge Hallyn] save_access_regs for self-checkpoint
  - [Serge Hallyn] send uses_interp=1 to arch_setup_additional_pages
Changelog [v19]:
  - [Serge Hallyn] Move get_signal_to_deliver() up in do_signal
Changelog [v19-rc3]:
  - [Serge Hallyn] Ue simpler test_task_thread to test current ti flags
  - [Serge Hallyn] Fix 31-bit s390 checkpoint/restart wrappers
  - [Serge Hallyn] Update sys_checkpoint (do_sys_checkpoint on all archs)
  - [Oren Laadan] Move checkpoint.c from arch/s390/mm->arch/s390/kernel
Changelog [v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Changelog:
    Jun 15:
            . Fix checkpoint and restart compat wrappers
    May 28:
            . Export asm/checkpoint_hdr.h to userspace
            . Define CKPT_ARCH_ID for S390
    Apr 11:
            . Introduce ckpt_arch_vdso()
    Feb 27:
            . Add checkpoint_s390.h
            . Fixed up save and restore of PSW, with the non-address bits
              properly masked out
    Feb 25:
            . Make checkpoint_hdr.h safe for inclusion in userspace
            . Replace comment about vsdo code
            . Add comment about restoring access registers
            . Write and read an empty ckpt_hdr_head_arch record to appease
              code (mktree) that expects it to be there
            . Utilize NUM_CKPT_WORDS in checkpoint_hdr.h
    Feb 24:
            . Use CKPT_COPY() to unify the un/loading of cpu and mm state
            . Fix fprs definition in ckpt_hdr_cpu
            . Remove debug WARN_ON() from checkpoint.c
    Feb 23:
            . Macro-ize the un/packing of trace flags
            . Fix the crash when externally-linked
            . Break out the restart functions into restart.c
            . Remove unneeded s390_enable_sie() call
    Jan 30:
            . Switched types in ckpt_hdr_cpu to __u64 etc.
              (Per Oren suggestion)
            . Replaced direct inclusion of structs in
              ckpt_hdr_cpu with the struct members.
              (Per Oren suggestion)
            . Also ended up adding a bunch of new things
              into restart (mm_segment, ksp, etc) in vain
              attempt to get code using fpu to not segfault
              after restart.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
---
 arch/s390/include/asm/Kbuild           |    1 +
 arch/s390/include/asm/checkpoint_hdr.h |   98 ++++++++++++
 arch/s390/include/asm/thread_info.h    |    2 +
 arch/s390/include/asm/unistd.h         |    4 +-
 arch/s390/kernel/Makefile              |    1 +
 arch/s390/kernel/checkpoint.c          |  258 ++++++++++++++++++++++++++++++++
 arch/s390/kernel/compat_wrapper.S      |   16 ++
 arch/s390/kernel/process.c             |   20 +++-
 arch/s390/kernel/signal.c              |   16 ++
 arch/s390/kernel/syscalls.S            |    2 +
 arch/s390/mm/Makefile                  |    1 +
 arch/s390/mm/checkpoint_s390.h         |   23 +++
 include/linux/checkpoint_hdr.h         |    3 +
 mm/mmap.c                              |    9 +-
 14 files changed, 451 insertions(+), 3 deletions(-)
 create mode 100644 arch/s390/include/asm/checkpoint_hdr.h
 create mode 100644 arch/s390/kernel/checkpoint.c
 create mode 100644 arch/s390/mm/checkpoint_s390.h

diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 63a2341..3282a6e 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -8,6 +8,7 @@ header-y += ucontext.h
 header-y += vtoc.h
 header-y += zcrypt.h
 header-y += chsc.h
+header-y += checkpoint_hdr.h
 
 unifdef-y += cmb.h
 unifdef-y += debug.h
diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..e3312c0
--- /dev/null
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -0,0 +1,98 @@
+#ifndef __ASM_S390_CKPT_HDR_H
+#define __ASM_S390_CKPT_HDR_H
+/*
+ *  Checkpoint/restart - architecture specific headers s/390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef _CHECKPOINT_CKPT_HDR_H_
+#error asm/checkpoint_hdr.h included directly
+#endif
+
+#include <linux/types.h>
+#include <asm/ptrace.h>
+
+#ifdef __KERNEL__
+#include <asm/processor.h>
+#endif
+
+#ifdef CONFIG_64BIT
+#define CKPT_ARCH_ID	CKPT_ARCH_S390X
+/* else - if we ever support 32bit - CKPT_ARCH_S390 */
+#endif
+
+/*
+ * Notes
+ * NUM_GPRS defined in <asm/ptrace.h> to be 16
+ * NUM_FPRS defined in <asm/ptrace.h> to be 16
+ * NUM_APRS defined in <asm/ptrace.h> to be 16
+ * NUM_CR_WORDS defined in <asm/ptrace.h> to be 3
+ *              but is not yet in glibc headers.
+ */
+
+#ifndef NUM_CR_WORDS
+#define NUM_CR_WORDS 3
+#endif
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	__u64 args[1];
+	__u64 gprs[NUM_GPRS];
+	__u64 orig_gpr2;
+	__u16 svcnr;
+	__u16 ilc;
+	__u32 acrs[NUM_ACRS];
+	__u64 ieee_instruction_pointer;
+
+	/* psw_t */
+	__u64 psw_t_mask;
+	__u64 psw_t_addr;
+
+	/* s390_fp_regs_t */
+	__u32 fpc;
+	union {
+		float f;
+		double d;
+		__u64 ui;
+		struct {
+			__u32 fp_hi;
+			__u32 fp_lo;
+		} fp;
+	} fprs[NUM_FPRS];
+
+	/* per_struct */
+	__u64 per_control_regs[NUM_CR_WORDS];
+	__u64 starting_addr;
+	__u64 ending_addr;
+	__u64 address;
+	__u16 perc_atmid;
+	__u8 access_id;
+	__u8 single_step;
+	__u8 instruction_fetch;
+};
+
+struct ckpt_hdr_thread {
+	struct ckpt_hdr h;
+	__u64 thread_info_flags;
+};
+
+struct ckpt_hdr_mm_context {
+	struct ckpt_hdr h;
+	unsigned long vdso_base;
+	int noexec;
+	int has_pgste;
+	int alloc_pgste;
+	unsigned long asce_bits;
+	unsigned long asce_limit;
+};
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+};
+
+#endif /* __ASM_S390_CKPT_HDR__H */
diff --git a/arch/s390/include/asm/thread_info.h b/arch/s390/include/asm/thread_info.h
index 66069e7..61e84e5 100644
--- a/arch/s390/include/asm/thread_info.h
+++ b/arch/s390/include/asm/thread_info.h
@@ -99,6 +99,7 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_MEMDIE		18
 #define TIF_RESTORE_SIGMASK	19	/* restore signal mask in do_signal() */
 #define TIF_FREEZE		20	/* thread is freezing for suspend */
+#define TIF_SIG_RESTARTBLOCK	23	/* restart must set TIF_RESTART_SVC */
 
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
@@ -114,6 +115,7 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_31BIT		(1<<TIF_31BIT)
 #define _TIF_FREEZE		(1<<TIF_FREEZE)
+#define _TIF_SIG_RESTARTBLOCK	(1<<TIF_SIG_RESTARTBLOCK)
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index 2250950..7c3b55e 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -270,7 +270,9 @@
 #define __NR_rt_tgsigqueueinfo	330
 #define __NR_perf_event_open	331
 #define __NR_eclone		332
-#define NR_syscalls 333
+#define __NR_checkpoint		333
+#define __NR_restart		334
+#define NR_syscalls 335
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/Makefile b/arch/s390/kernel/Makefile
index 683f638..5fdde07 100644
--- a/arch/s390/kernel/Makefile
+++ b/arch/s390/kernel/Makefile
@@ -33,6 +33,7 @@ extra-y				+= head.o init_task.o vmlinux.lds
 obj-$(CONFIG_MODULES)		+= s390_ksyms.o module.o
 obj-$(CONFIG_SMP)		+= smp.o topology.o
 obj-$(CONFIG_HIBERNATION)	+= suspend.o swsusp_asm64.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
 obj-$(CONFIG_AUDIT)		+= audit.o
 compat-obj-$(CONFIG_AUDIT)	+= compat_audit.o
 obj-$(CONFIG_COMPAT)		+= compat_linux.o compat_signal.o \
diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
new file mode 100644
index 0000000..79f0a2f
--- /dev/null
+++ b/arch/s390/kernel/checkpoint.c
@@ -0,0 +1,258 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+#include <asm/elf.h>
+#include <asm/unistd.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
+			   struct task_struct *t)
+{
+	struct pt_regs *regs = task_pt_regs(t);
+	struct thread_struct *thr = &t->thread;
+
+	/* Save the whole PSW to facilitate forensic debugging, but only
+	 * restore the address portion to avoid letting userspace do
+	 * bad things by manipulating its value.
+	 */
+	if (op == CKPT_CPT) {
+		CKPT_COPY(op, h->psw_t_addr, regs->psw.addr);
+	} else {
+		regs->psw.addr &= ~PSW_ADDR_INSN;
+		regs->psw.addr |= h->psw_t_addr;
+	}
+
+	CKPT_COPY(op, h->args[0], regs->args[0]);
+	CKPT_COPY(op, h->orig_gpr2, regs->orig_gpr2);
+	CKPT_COPY(op, h->svcnr, regs->svcnr);
+	CKPT_COPY(op, h->ilc, regs->ilc);
+	CKPT_COPY(op, h->ieee_instruction_pointer,
+		thr->ieee_instruction_pointer);
+	CKPT_COPY(op, h->psw_t_mask, regs->psw.mask);
+	CKPT_COPY(op, h->fpc, thr->fp_regs.fpc);
+	CKPT_COPY(op, h->starting_addr, thr->per_info.starting_addr);
+	CKPT_COPY(op, h->ending_addr, thr->per_info.ending_addr);
+	CKPT_COPY(op, h->address, thr->per_info.lowcore.words.address);
+	CKPT_COPY(op, h->perc_atmid, thr->per_info.lowcore.words.perc_atmid);
+	CKPT_COPY(op, h->access_id, thr->per_info.lowcore.words.access_id);
+	CKPT_COPY(op, h->single_step, thr->per_info.single_step);
+	CKPT_COPY(op, h->instruction_fetch, thr->per_info.instruction_fetch);
+
+	CKPT_COPY_ARRAY(op, h->gprs, regs->gprs, NUM_GPRS);
+	/*
+	 * for checkpoint in process context (from within a container),
+	 * the actual syscall is taking place at this very moment; so
+	 * we (optimistically) subtitute the future return value (0) of
+	 * this syscall into the orig_eax, so that upon restart it will
+	 * succeed (or it will endlessly retry checkpoint...)
+	 */
+	if (op == CKPT_CPT && t == current) {
+		BUG_ON(h->gprs[2] < 0);
+		h->gprs[2] = 0;
+	}
+
+	/*
+	 * if a checkpoint was taken while interrupted from a restartable
+	 * syscall, then treat this as though signr==0 (since we did not
+	 * handle the signal) and finish the last part of do_signal
+	 */
+	if (op == CKPT_RST && test_thread_flag(TIF_SIG_RESTARTBLOCK)) {
+		regs->gprs[2] = __NR_restart_syscall;
+		set_thread_flag(TIF_RESTART_SVC);
+		clear_thread_flag(TIF_SIG_RESTARTBLOCK);
+	}
+
+	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
+	if (op == CKPT_CPT && t == current) {
+		save_access_regs(h->acrs);
+	} else {
+		CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
+	}
+	CKPT_COPY_ARRAY(op, h->per_control_regs,
+		      thr->per_info.control_regs.words.cr, NUM_CR_WORDS);
+}
+
+static void s390_mm(int op, struct ckpt_hdr_mm_context *h,
+		    struct mm_struct *mm)
+{
+	CKPT_COPY(op, h->noexec, mm->context.noexec);
+	CKPT_COPY(op, h->has_pgste, mm->context.has_pgste);
+	CKPT_COPY(op, h->alloc_pgste, mm->context.alloc_pgste);
+	CKPT_COPY(op, h->asce_bits, mm->context.asce_bits);
+	CKPT_COPY(op, h->asce_limit, mm->context.asce_limit);
+}
+
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_thread *h;
+	int ret;
+
+	/* we will eventually support this, as we do on x86-64 */
+	if (test_tsk_thread_flag(t, TIF_31BIT)) {
+		ckpt_err(ctx, -EINVAL, "checkpoint of 31-bit task\n");
+		return -EINVAL;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (!h)
+		return -ENOMEM;
+
+	h->thread_info_flags = task_thread_info(t)->flags;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (!h)
+		return -ENOMEM;
+
+	s390_copy_regs(CKPT_CPT, h, t);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/* Write an empty header since it is assumed to be there */
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (!h)
+		return -ENOMEM;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (!h)
+		return -ENOMEM;
+
+	s390_mm(CKPT_CPT, h, mm);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+int restore_thread(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_thread *h;
+
+	/* a 31-bit task cannot call sys_restart right now */
+	if (test_thread_flag(TIF_31BIT)) {
+		ckpt_err(ctx, -EINVAL, "restart from 31-bit task\n");
+		return -EINVAL;
+	}
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/*
+	 * If we were checkpointed while do_signal() interrupted a
+	 * syscall with restart blocks, then we have some cleanup to
+	 * do at end of restart, in order to finish our pretense of
+	 * having handled signr==0.  (See last part of do_signal).
+	 *
+	 * We can't set gprs[2] here bc we haven't copied registers
+	 * yet, that happens later in restore_cpu().  So re-set the
+	 * TIF_SIG_RESTARTBLOCK thread flag so we can detect it
+	 * at restore_cpu()->s390_copy_regs() and do the right thing.
+	 */
+	if (h->thread_info_flags & _TIF_SIG_RESTARTBLOCK)
+		set_thread_flag(TIF_SIG_RESTARTBLOCK);
+
+	/* will have to handle TIF_RESTORE_SIGMASK as well */
+
+	ckpt_hdr_put(ctx, h);
+
+	return 0;
+}
+
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	s390_copy_regs(CKPT_RST, h, current);
+
+	/* s390 does not restore the access registers after a syscall,
+	 * but does on a task switch.  Since we're switching tasks (in
+	 * a way), we need to replicate that behavior here.
+	 */
+	restore_access_regs(h->acrs);
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	s390_mm(CKPT_RST, h, mm);
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
index cfa227e..3a3e246 100644
--- a/arch/s390/kernel/compat_wrapper.S
+++ b/arch/s390/kernel/compat_wrapper.S
@@ -1861,3 +1861,19 @@ sys32_execve_wrapper:
 	llgtr	%r3,%r3			# compat_uptr_t *
 	llgtr	%r4,%r4			# compat_uptr_t *
 	jg	sys32_execve		# branch to system call
+
+	.globl sys_checkpoint_wrapper
+sys_checkpoint_wrapper:
+	lgfr	%r2,%r2			# pid_t
+	lgfr	%r3,%r3			# int
+	llgfr	%r4,%r4			# unsigned long
+	lgfr	%r5,%r5			# int
+	jg	sys_checkpoint
+
+	.globl sys_restart_wrapper
+sys_restart_wrapper:
+	lgfr	%r2,%r2			# pid_t
+	lgfr	%r3,%r3			# int
+	llgfr	%r4,%r4			# unsigned long
+	lgfr	%r5,%r5			# int
+	jg	sys_restart
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index eb834fd..855111c 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -32,6 +32,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/syscalls.h>
 #include <linux/compat.h>
+#include <linux/checkpoint.h>
 #include <asm/compat.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -241,12 +242,29 @@ SYSCALL_DEFINE4(clone, unsigned long, newsp, unsigned long, clone_flags,
 }
 
 #ifdef CONFIG_CHECKPOINT
-extern long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
+{
+	return do_sys_checkpoint(pid, fd, flags, logfd);
+}
+
 SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags,
 		int, logfd)
 {
 	return do_sys_restart(pid, fd, flags, logfd);
 }
+#else
+SYSCALL_DEFINE4(checkpoint, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
+{
+	return -ENOSYS;
+}
+
+SYSCALL_DEFINE4(restart, pid_t, pid, int, fd, unsigned long, flags,
+		int, logfd)
+{
+	return -ENOSYS;
+}
 #endif
 
 SYSCALL_DEFINE4(eclone, unsigned int, flags_low, struct clone_args __user *,
diff --git a/arch/s390/kernel/signal.c b/arch/s390/kernel/signal.c
index 6289945..83425b1 100644
--- a/arch/s390/kernel/signal.c
+++ b/arch/s390/kernel/signal.c
@@ -459,6 +459,16 @@ void do_signal(struct pt_regs *regs)
 			break;
 		case -ERESTART_RESTARTBLOCK:
 			regs->gprs[2] = -EINTR;
+			/*
+			 * This condition is the only one which requires
+			 * special care after handling a signr==0.  So if
+			 * we get frozen and checkpointed at the
+			 * get_signal_to_deliver() below, then we need
+			 * to convey this condition to sys_restart() so it
+			 * can set the restored thread up to run the restart
+			 * block.
+			 */
+			set_thread_flag(TIF_SIG_RESTARTBLOCK);
 		}
 		regs->svcnr = 0;	/* Don't deal with this again. */
 	}
@@ -467,6 +477,12 @@ void do_signal(struct pt_regs *regs)
 	   the debugger may change all our registers ... */
 	signr = get_signal_to_deliver(&info, &ka, regs, NULL);
 
+	/*
+	 * we won't get frozen past this so clear the thread flag hinting
+	 * to sys_restart that TIF_RESTART_SVC must be set.
+	 */
+	clear_thread_flag(TIF_SIG_RESTARTBLOCK);
+
 	/* Depending on the signal settings we may need to revert the
 	   decision to restart the system call. */
 	if (signr > 0 && regs->psw.addr == restart_addr) {
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index fb8708d..a29f9e1 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -341,3 +341,5 @@ SYSCALL(sys_pwritev,sys_pwritev,compat_sys_pwritev_wrapper)
 SYSCALL(sys_rt_tgsigqueueinfo,sys_rt_tgsigqueueinfo,compat_sys_rt_tgsigqueueinfo_wrapper) /* 330 */
 SYSCALL(sys_perf_event_open,sys_perf_event_open,sys_perf_event_open_wrapper)
 SYSCALL(sys_eclone,sys_eclone,sys_eclone_wrapper)
+SYSCALL(sys_checkpoint,sys_checkpoint,sys_checkpoint_wrapper)
+SYSCALL(sys_restart,sys_restart,sys_restart_wrapper)
diff --git a/arch/s390/mm/Makefile b/arch/s390/mm/Makefile
index eec0544..359a3bc 100644
--- a/arch/s390/mm/Makefile
+++ b/arch/s390/mm/Makefile
@@ -6,3 +6,4 @@ obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o maccess.o \
 	    page-states.o
 obj-$(CONFIG_CMM) += cmm.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
+obj-$(CONFIG_PAGE_STATES) += page-states.o
diff --git a/arch/s390/mm/checkpoint_s390.h b/arch/s390/mm/checkpoint_s390.h
new file mode 100644
index 0000000..c3bf24d
--- /dev/null
+++ b/arch/s390/mm/checkpoint_s390.h
@@ -0,0 +1,23 @@
+/*
+ *  Checkpoint/restart - architecture specific support for s390
+ *
+ *  Copyright IBM Corp. 2009
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef _S390_CHECKPOINT_H
+#define _S390_CHECKPOINT_H
+
+#include <linux/checkpoint_hdr.h>
+#include <linux/sched.h>
+#include <linux/mm_types.h>
+
+extern void checkpoint_s390_regs(int op, struct ckpt_hdr_cpu *h,
+				 struct task_struct *t);
+extern void checkpoint_s390_mm(int op, struct ckpt_hdr_mm_context *h,
+			       struct mm_struct *mm);
+
+#endif /* _S390_CHECKPOINT_H */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 64c3f8f..825f4cc 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -128,10 +128,13 @@ enum {
 
 /* architecture */
 enum {
+	/* do not change order (will break ABI) */
 	CKPT_ARCH_X86_32 = 1,
 #define CKPT_ARCH_X86_32 CKPT_ARCH_X86_32
 	CKPT_ARCH_X86_64,
 #define CKPT_ARCH_X86_64 CKPT_ARCH_X86_64
+	CKPT_ARCH_S390X,
+#define CKPT_ARCH_S390X CKPT_ARCH_S390X
 };
 
 /* shared objrects (objref) */
diff --git a/mm/mmap.c b/mm/mmap.c
index 83ad953..0e8ef05 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2411,7 +2411,14 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
 		ret = syscall32_setup_pages(NULL, h->vm_start, 0);
 	else
 #endif
-	ret = arch_setup_additional_pages(NULL, h->vm_start, 0);
+	/*
+	 * Pass uses_interp=1 to arch_setup_additional_pages because
+	 * s390 won't set up vdso if it is 0. Here it's safe to assume
+	 * that there is a vdso in the checkpoint image, and therefore
+	 * the checkpointed program was dynamically linked. The other
+	 * architectures ignore uses_interp altogether.
+	 */
+	ret = arch_setup_additional_pages(NULL, h->vm_start, 1);
 #endif
 
 	return ret;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
