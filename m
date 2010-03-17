Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC2162003F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:29:21 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 89/96] powerpc: checkpoint/restart implementation
Date: Wed, 17 Mar 2010 12:09:17 -0400
Message-Id: <1268842164-5590-90-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-89-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-64-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-65-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-66-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-67-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-68-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-69-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-70-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-71-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-72-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-73-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-74-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-75-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-76-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-77-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-78-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-79-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-80-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-81-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-82-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-83-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-84-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-85-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-86-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-87-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-88-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-89-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Nathan Lynch <ntl@pobox.com>
List-ID: <linux-mm.kvack.org>

From: Nathan Lynch <ntl@pobox.com>

Support for checkpointing and restarting GPRs, FPU state, DABR, and
Altivec state.

The portion of the checkpoint image manipulated by this code begins
with a bitmask of features indicating the various contexts saved.
Fields in image that can vary depending on kernel configuration
(e.g. FP regs due to VSX) have their sizes explicitly recorded, except
for GPRS, so migrating between ppc32 and ppc64 won't work yet.

The restart code ensures that the task is not modified until the
checkpoint image is validated against the current kernel configuration
and hardware features (e.g. can't restart a task using Altivec on
non-Altivec systems).

What works:
* self and external checkpoint of simple (single thread, one open
  file) 32- and 64-bit processes on a ppc64 kernel

What doesn't work:
* restarting a 32-bit task from a 64-bit task and vice versa

Untested:
* ppc32 (but it builds)

Changelog[v19]:
  - [Serge Hallyn] Add hook task_has_saved_sigmask()
Changelog[v19-rc3]:
  - [Oren Laadan] Move checkpoint.c from arch/powerpc/{mm->kernel}
  - [Nathan Lynch] Warn if full register state unavailable

Signed-off-by: Nathan Lynch <ntl@pobox.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
[Oren Laadan <orenl@cs.columbia.edu>] Add arch-specific tty support
---
 arch/powerpc/include/asm/Kbuild           |    1 +
 arch/powerpc/include/asm/checkpoint_hdr.h |   37 ++
 arch/powerpc/kernel/Makefile              |    1 +
 arch/powerpc/kernel/checkpoint.c          |  533 +++++++++++++++++++++++++++++
 arch/powerpc/kernel/signal.c              |    6 +
 5 files changed, 578 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/include/asm/checkpoint_hdr.h
 create mode 100644 arch/powerpc/kernel/checkpoint.c

diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 5ab7d7f..20379f1 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -12,6 +12,7 @@ header-y += shmbuf.h
 header-y += socket.h
 header-y += termbits.h
 header-y += fcntl.h
+header-y += checkpoint_hdr.h
 header-y += poll.h
 header-y += sockios.h
 header-y += ucontext.h
diff --git a/arch/powerpc/include/asm/checkpoint_hdr.h b/arch/powerpc/include/asm/checkpoint_hdr.h
new file mode 100644
index 0000000..fbb1705
--- /dev/null
+++ b/arch/powerpc/include/asm/checkpoint_hdr.h
@@ -0,0 +1,37 @@
+#ifndef __ASM_POWERPC_CKPT_HDR_H
+#define __ASM_POWERPC_CKPT_HDR_H
+
+#include <linux/types.h>
+
+/* arch dependent constants */
+#define CKPT_ARCH_NSIG 64
+#define CKPT_TTY_NCC  10
+
+#ifdef __KERNEL__
+
+#include <asm/signal.h>
+#if CKPT_ARCH_NSIG != _NSIG
+#error CKPT_ARCH_NSIG size is wrong per asm/signal.h and asm/checkpoint_hdr.h
+#endif
+
+#include <linux/tty.h>
+#if CKPT_TTY_NCC != NCC
+#error CKPT_TTY_NCC size is wrong per asm-generic/termios.h
+#endif
+
+#endif /* __KERNEL__ */
+
+#ifdef __KERNEL__
+#ifdef CONFIG_PPC64
+#define CKPT_ARCH_ID CKPT_ARCH_PPC64
+#else
+#define CKPT_ARCH_ID CKPT_ARCH_PPC32
+#endif
+#endif
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+	__u32 what;
+} __attribute__((aligned(8)));
+
+#endif /* __ASM_POWERPC_CKPT_HDR_H */
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index c002b04..b5bd090 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -63,6 +63,7 @@ obj64-$(CONFIG_HIBERNATION)	+= swsusp_asm64.o
 obj-$(CONFIG_MODULES)		+= module.o module_$(CONFIG_WORD_SIZE).o
 obj-$(CONFIG_44x)		+= cpu_setup_44x.o
 obj-$(CONFIG_FSL_BOOKE)		+= cpu_setup_fsl_booke.o dbell.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
 
 extra-y				:= head_$(CONFIG_WORD_SIZE).o
 extra-$(CONFIG_PPC_BOOK3E_32)	:= head_new_booke.o
diff --git a/arch/powerpc/kernel/checkpoint.c b/arch/powerpc/kernel/checkpoint.c
new file mode 100644
index 0000000..2634011
--- /dev/null
+++ b/arch/powerpc/kernel/checkpoint.c
@@ -0,0 +1,533 @@
+/*
+ * PowerPC architecture support for checkpoint/restart.
+ * Based on x86 implementation.
+ *
+ * Copyright (C) 2008 Oren Laadan
+ * Copyright 2009 IBM Corp.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ */
+
+#if 0
+#define DEBUG
+#endif
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/kernel.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/system.h>
+
+enum ckpt_cpu_feature {
+	CKPT_USED_FP,
+	CKPT_USED_DEBUG,
+	CKPT_USED_ALTIVEC,
+	CKPT_USED_SPE,
+	CKPT_USED_VSX,
+	CKPT_FTR_END = 31,
+};
+
+#define x(ftr) (1UL << ftr)
+
+/* features this kernel can handle for restart */
+enum {
+	CKPT_FTRS_POSSIBLE =
+#ifdef CONFIG_PPC_FPU
+	x(CKPT_USED_FP) |
+#endif
+	x(CKPT_USED_DEBUG) |
+#ifdef CONFIG_ALTIVEC
+	x(CKPT_USED_ALTIVEC) |
+#endif
+#ifdef CONFIG_SPE
+	x(CKPT_USED_SPE) |
+#endif
+#ifdef CONFIG_VSX
+	x(CKPT_USED_VSX) |
+#endif
+	0,
+};
+
+#undef x
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	u32 features_used;
+	u32 pt_regs_size;
+	u32 fpr_size;
+	u64 orig_gpr3;
+	struct pt_regs pt_regs;
+	/* relevant fields from thread_struct */
+	double fpr[32][TS_FPRWIDTH];
+	u32 fpscr;
+	s32 fpexc_mode;
+	u64 dabr;
+	/* Altivec/VMX state */
+	vector128 vr[32];
+	vector128 vscr;
+	u64 vrsave;
+	/* SPE state */
+	u32 evr[32];
+	u64 acc;
+	u32 spefscr;
+};
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+static void ckpt_cpu_feature_set(struct ckpt_hdr_cpu *hdr,
+				 enum ckpt_cpu_feature ftr)
+{
+	hdr->features_used |= 1ULL << ftr;
+}
+
+static bool ckpt_cpu_feature_isset(const struct ckpt_hdr_cpu *hdr,
+				 enum ckpt_cpu_feature ftr)
+{
+	return hdr->features_used & (1ULL << ftr);
+}
+
+/* determine whether an image has feature bits set that this kernel
+ * does not support */
+static bool ckpt_cpu_features_unknown(const struct ckpt_hdr_cpu *hdr)
+{
+	return hdr->features_used & ~CKPT_FTRS_POSSIBLE;
+}
+
+static void checkpoint_gprs(struct ckpt_hdr_cpu *cpu_hdr,
+			    struct task_struct *task)
+{
+	struct pt_regs *pt_regs;
+
+	pr_debug("%s: saving GPRs\n", __func__);
+
+	cpu_hdr->pt_regs_size = sizeof(*pt_regs);
+	pt_regs = task_pt_regs(task);
+	WARN_ON(!FULL_REGS(pt_regs));
+
+	cpu_hdr->pt_regs = *pt_regs;
+
+	if (task == current)
+		cpu_hdr->pt_regs.gpr[3] = 0;
+
+	cpu_hdr->orig_gpr3 = pt_regs->orig_gpr3;
+}
+
+#ifdef CONFIG_PPC_FPU
+static void checkpoint_fpu(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	/* easiest to save FP state unconditionally */
+
+	pr_debug("%s: saving FPU state\n", __func__);
+
+	if (task == current)
+		flush_fp_to_thread(task);
+
+	cpu_hdr->fpr_size = sizeof(cpu_hdr->fpr);
+	cpu_hdr->fpscr = task->thread.fpscr.val;
+	cpu_hdr->fpexc_mode = task->thread.fpexc_mode;
+
+	memcpy(cpu_hdr->fpr, task->thread.fpr, sizeof(cpu_hdr->fpr));
+
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_FP);
+}
+#else
+static void checkpoint_fpu(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_ALTIVEC
+static void checkpoint_altivec(struct ckpt_hdr_cpu *cpu_hdr,
+			       struct task_struct *task)
+{
+	if (!cpu_has_feature(CPU_FTR_ALTIVEC))
+		return;
+
+	if (!task->thread.used_vr)
+		return;
+
+	pr_debug("%s: saving Altivec state\n", __func__);
+
+	if (task == current)
+		flush_altivec_to_thread(task);
+
+	cpu_hdr->vrsave = task->thread.vrsave;
+	memcpy(cpu_hdr->vr, task->thread.vr, sizeof(cpu_hdr->vr));
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_ALTIVEC);
+}
+#else
+static void checkpoint_altivec(struct ckpt_hdr_cpu *cpu_hdr,
+			       struct task_struct *task)
+{
+	return;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static void checkpoint_spe(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	if (!cpu_has_feature(CPU_FTR_SPE))
+		return;
+
+	if (!task->thread.used_spe)
+		return;
+
+	pr_debug("%s: saving SPE state\n", __func__);
+
+	if (task == current)
+		flush_spe_to_thread(task);
+
+	cpu_hdr->acc = task->thread.acc;
+	cpu_hdr->spefscr = task->thread.spefscr;
+	memcpy(cpu_hdr->evr, task->thread.evr, sizeof(cpu_hdr->evr));
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_SPE);
+}
+#else
+static void checkpoint_spe(struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task)
+{
+	return;
+}
+#endif
+
+static void checkpoint_dabr(struct ckpt_hdr_cpu *cpu_hdr,
+			    const struct task_struct *task)
+{
+	if (!task->thread.dabr)
+		return;
+
+	cpu_hdr->dabr = task->thread.dabr;
+	ckpt_cpu_feature_set(cpu_hdr, CKPT_USED_DEBUG);
+}
+
+/* dump the thread_struct of a given task */
+int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	return 0;
+}
+
+/* dump the cpu state and registers of a given task */
+int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_cpu *cpu_hdr;
+	int rc;
+
+	rc = -ENOMEM;
+	cpu_hdr = ckpt_hdr_get_type(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
+	if (!cpu_hdr)
+		goto err;
+
+	checkpoint_gprs(cpu_hdr, t);
+	checkpoint_fpu(cpu_hdr, t);
+	checkpoint_dabr(cpu_hdr, t);
+	checkpoint_altivec(cpu_hdr, t);
+	checkpoint_spe(cpu_hdr, t);
+
+	rc = ckpt_write_obj(ctx, (struct ckpt_hdr *) cpu_hdr);
+err:
+	ckpt_hdr_put(ctx, cpu_hdr);
+	return rc;
+}
+
+int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+	int ret;
+
+	arch_hdr = ckpt_hdr_get_type(ctx, sizeof(*arch_hdr),
+				     CKPT_HDR_HEADER_ARCH);
+	if (!arch_hdr)
+		return -ENOMEM;
+
+	arch_hdr->what = 0xdeadbeef;
+
+	ret = ckpt_write_obj(ctx, &arch_hdr->h);
+	ckpt_hdr_put(ctx, arch_hdr);
+
+	return ret;
+}
+
+/* dump the mm->context state */
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/* read the thread_struct into the current task */
+int restore_thread(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+/* Based on the MSR value from a checkpoint image, produce an MSR
+ * value that is appropriate for the restored task.  Right now we only
+ * check for MSR_SF (64-bit) for PPC64.
+ */
+static unsigned long sanitize_msr(unsigned long msr_ckpt)
+{
+#ifdef CONFIG_PPC32
+	return MSR_USER;
+#else
+	if (msr_ckpt & MSR_SF)
+		return MSR_USER64;
+	return MSR_USER32;
+#endif
+}
+
+static int restore_gprs(const struct ckpt_hdr_cpu *cpu_hdr,
+			struct task_struct *task, bool update)
+{
+	struct pt_regs *regs;
+	int rc;
+
+	rc = -EINVAL;
+	if (cpu_hdr->pt_regs_size != sizeof(*regs))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	regs = task_pt_regs(task);
+	*regs = cpu_hdr->pt_regs;
+
+	regs->orig_gpr3 = cpu_hdr->orig_gpr3;
+
+	regs->msr = sanitize_msr(regs->msr);
+out:
+	return rc;
+}
+
+#ifdef CONFIG_PPC_FPU
+static int restore_fpu(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = -EINVAL;
+	if (cpu_hdr->fpr_size != sizeof(task->thread.fpr))
+		goto out;
+
+	rc = 0;
+	if (!update || !ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_FP))
+		goto out;
+
+	task->thread.fpscr.val = cpu_hdr->fpscr;
+	task->thread.fpexc_mode = cpu_hdr->fpexc_mode;
+
+	memcpy(task->thread.fpr, cpu_hdr->fpr, sizeof(task->thread.fpr));
+out:
+	return rc;
+}
+#else
+static int restore_fpu(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_FP));
+	return 0;
+}
+#endif
+
+static int restore_dabr(const struct ckpt_hdr_cpu *cpu_hdr,
+			struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_DEBUG))
+		goto out;
+
+	rc = -EINVAL;
+	if (!debugreg_valid(cpu_hdr->dabr, 0))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	debugreg_update(task, cpu_hdr->dabr, 0);
+out:
+	return rc;
+}
+
+#ifdef CONFIG_ALTIVEC
+static int restore_altivec(const struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_ALTIVEC))
+		goto out;
+
+	rc = -EINVAL;
+	if (!cpu_has_feature(CPU_FTR_ALTIVEC))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	task->thread.vrsave = cpu_hdr->vrsave;
+	task->thread.used_vr = 1;
+
+	memcpy(task->thread.vr, cpu_hdr->vr, sizeof(cpu_hdr->vr));
+out:
+	return rc;
+}
+#else
+static int restore_altivec(const struct ckpt_hdr_cpu *cpu_hdr,
+			   struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(CKPT_USED_ALTIVEC));
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_SPE
+static int restore_spe(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	int rc;
+
+	rc = 0;
+	if (!ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE))
+		goto out;
+
+	rc = -EINVAL;
+	if (!cpu_has_feature(CPU_FTR_SPE))
+		goto out;
+
+	rc = 0;
+	if (!update)
+		goto out;
+
+	task->thread.acc = cpu_hdr->acc;
+	task->thread.spefscr = cpu_hdr->spefscr;
+	task->thread.used_spe = 1;
+
+	memcpy(task->thread.evr, cpu_hdr->evr, sizeof(cpu_hdr->evr));
+out:
+	return rc;
+}
+#else
+static int restore_spe(const struct ckpt_hdr_cpu *cpu_hdr,
+		       struct task_struct *task, bool update)
+{
+	WARN_ON_ONCE(ckpt_cpu_feature_isset(cpu_hdr, CKPT_USED_SPE));
+	return 0;
+}
+#endif
+
+struct restore_func_desc {
+	int (*func)(const struct ckpt_hdr_cpu *, struct task_struct *, bool);
+	const char *info;
+};
+
+typedef int (*restore_func_t)(const struct ckpt_hdr_cpu *,
+			      struct task_struct *, bool);
+
+static const restore_func_t restore_funcs[] = {
+	restore_gprs,
+	restore_fpu,
+	restore_dabr,
+	restore_altivec,
+	restore_spe,
+};
+
+static bool bitness_match(const struct ckpt_hdr_cpu *cpu_hdr,
+			  const struct task_struct *task)
+{
+	/* 64-bit image */
+	if (cpu_hdr->pt_regs.msr & MSR_SF) {
+		if (task->thread.regs->msr & MSR_SF)
+			return true;
+		else
+			return false;
+	}
+
+	/* 32-bit image */
+	if (task->thread.regs->msr & MSR_SF)
+		return false;
+
+	return true;
+}
+
+int restore_cpu(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_cpu *cpu_hdr;
+	bool update;
+	int rc;
+	int i;
+
+	cpu_hdr = ckpt_read_obj_type(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
+	if (IS_ERR(cpu_hdr))
+		return PTR_ERR(cpu_hdr);
+
+	rc = -EINVAL;
+	if (ckpt_cpu_features_unknown(cpu_hdr))
+		goto err;
+
+	/* temporary: restoring a 32-bit image from a 64-bit task and
+	 * vice-versa is known not to work (probably not restoring
+	 * thread_info correctly); detect this and fail gracefully.
+	 */
+	if (!bitness_match(cpu_hdr, current))
+		goto err;
+
+	/* We want to determine whether there's anything wrong with
+	 * the checkpoint image before changing the task at all.  Run
+	 * a "check" phase (update = false) first.
+	 */
+	update = false;
+commit:
+	for (i = 0; i < ARRAY_SIZE(restore_funcs); i++) {
+		rc = restore_funcs[i](cpu_hdr, current, update);
+		if (rc == 0)
+			continue;
+		pr_debug("%s: restore_func[%i] failed\n", __func__, i);
+		WARN_ON_ONCE(update);
+		goto err;
+	}
+
+	if (!update) {
+		update = true;
+		goto commit;
+	}
+
+err:
+	ckpt_hdr_put(ctx, cpu_hdr);
+	return rc;
+}
+
+int restore_read_header_arch(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header_arch *arch_hdr;
+
+	arch_hdr = ckpt_read_obj_type(ctx, sizeof(*arch_hdr),
+				      CKPT_HDR_HEADER_ARCH);
+	if (IS_ERR(arch_hdr))
+		return PTR_ERR(arch_hdr);
+
+	ckpt_hdr_put(ctx, arch_hdr);
+
+	return 0;
+}
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	return 0;
+}
diff --git a/arch/powerpc/kernel/signal.c b/arch/powerpc/kernel/signal.c
index 00b5078..701a064 100644
--- a/arch/powerpc/kernel/signal.c
+++ b/arch/powerpc/kernel/signal.c
@@ -188,6 +188,12 @@ static int do_signal_pending(sigset_t *oldset, struct pt_regs *regs)
 	return ret;
 }
 
+int task_has_saved_sigmask(struct task_struct *task)
+{
+	struct thread_info *ti = task_thread_info(task);
+	return !!(ti->local_flags & _TLF_RESTORE_SIGMASK);
+}
+
 void do_signal(struct pt_regs *regs, unsigned long thread_info_flags)
 {
 	if (thread_info_flags & _TIF_SIGPENDING)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
