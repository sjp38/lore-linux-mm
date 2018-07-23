Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B39176B0005
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:25:17 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e93-v6so13358146plb.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 02:25:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u19-v6si8632736pgb.629.2018.07.23.02.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 02:25:16 -0700 (PDT)
Subject: Patch "x86/mm: Give each mm TLB flush generation a unique ID" has been added to the 4.4-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 23 Jul 2018 11:22:48 +0200
In-Reply-To: <153156072694.10043.1719994417190491710.stgit@srivatsa-ubuntu>
Message-ID: <1532337768155131@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 413a91c24dab3ed0caa5f4e4d017d87b0857f920.1498751203.git.luto@kernel.org, akpm@linux-foundation.org, amakhalov@vmware.com, arjan@linux.intel.com, bp@alien8.de, dave.hansen@intel.com, ganb@vmware.com, gregkh@linuxfoundation.org, linux-mm@kvack.orgluto@kernel.org, matt.helsley@gmail.com, mgorman@suse.de, mingo@kernel.org, nadav.amit@gmail.com, peterz@infradead.org, riel@redhat.com, rostedt@goodmis.org, srivatsa@csail.mit.edu, srivatsab@vmware.com, tglx@linutronix.de, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Give each mm TLB flush generation a unique ID

to the 4.4-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-give-each-mm-tlb-flush-generation-a-unique-id.patch
and it can be found in the queue-4.4 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Mon Jul 23 10:04:05 CEST 2018
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Date: Sat, 14 Jul 2018 02:32:07 -0700
Subject: x86/mm: Give each mm TLB flush generation a unique ID
To: gregkh@linuxfoundation.org, stable@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, "Matt Helsley \(VMware\)" <matt.helsley@gmail.com>, Alexey Makhalov <amakhalov@vmware.com>, Bo Gan <ganb@vmware.com>, matt.helsley@gmail.com, rostedt@goodmis.org, amakhalov@vmware.com, ganb@vmware.com, srivatsa@csail.mit.edu, srivatsab@vmware.com
Message-ID: <153156072694.10043.1719994417190491710.stgit@srivatsa-ubuntu>

From: Andy Lutomirski <luto@kernel.org>

commit f39681ed0f48498b80455095376f11535feea332 upstream.

This adds two new variables to mmu_context_t: ctx_id and tlb_gen.
ctx_id uniquely identifies the mm_struct and will never be reused.
For a given mm_struct (and hence ctx_id), tlb_gen is a monotonic
count of the number of times that a TLB flush has been requested.
The pair (ctx_id, tlb_gen) can be used as an identifier for TLB
flush actions and will be used in subsequent patches to reliably
determine whether all needed TLB flushes have occurred on a given
CPU.

This patch is split out for ease of review.  By itself, it has no
real effect other than creating and updating the new variables.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/413a91c24dab3ed0caa5f4e4d017d87b0857f920.1498751203.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Srivatsa S. Bhat <srivatsa@csail.mit.edu>
Reviewed-by: Matt Helsley (VMware) <matt.helsley@gmail.com>
Reviewed-by: Alexey Makhalov <amakhalov@vmware.com>
Reviewed-by: Bo Gan <ganb@vmware.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

 arch/x86/include/asm/mmu.h         |   15 +++++++++++++--
 arch/x86/include/asm/mmu_context.h |    4 ++++
 arch/x86/mm/tlb.c                  |    2 ++
 3 files changed, 19 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -3,12 +3,18 @@
 
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
+#include <linux/atomic.h>
 
 /*
- * The x86 doesn't have a mmu context, but
- * we put the segment information here.
+ * x86 has arch-specific MMU state beyond what lives in mm_struct.
  */
 typedef struct {
+	/*
+	 * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
+	 * be reused, and zero is not a valid ctx_id.
+	 */
+	u64 ctx_id;
+
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	struct ldt_struct *ldt;
 #endif
@@ -24,6 +30,11 @@ typedef struct {
 	atomic_t perf_rdpmc_allowed;	/* nonzero if rdpmc is allowed */
 } mm_context_t;
 
+#define INIT_MM_CONTEXT(mm)						\
+	.context = {							\
+		.ctx_id = 1,						\
+	}
+
 void leave_mm(int cpu);
 
 #endif /* _ASM_X86_MMU_H */
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -11,6 +11,9 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+
+extern atomic64_t last_mm_ctx_id;
+
 #ifndef CONFIG_PARAVIRT
 static inline void paravirt_activate_mm(struct mm_struct *prev,
 					struct mm_struct *next)
@@ -105,6 +108,7 @@ static inline void enter_lazy_tlb(struct
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
 	init_new_context_ldt(tsk, mm);
 	return 0;
 }
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -29,6 +29,8 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
+atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
+
 struct flush_tlb_info {
 	struct mm_struct *flush_mm;
 	unsigned long flush_start;


Patches currently in stable-queue which might be from srivatsa@csail.mit.edu are

queue-4.4/x86-bugs-rename-_rds-to-_ssbd.patch
queue-4.4/x86-speculation-remove-skylake-c2-from-speculation-control-microcode-blacklist.patch
queue-4.4/documentation-spec_ctrl-do-some-minor-cleanups.patch
queue-4.4/x86-speculation-handle-ht-correctly-on-amd.patch
queue-4.4/x86-cpufeatures-add-x86_feature_rds.patch
queue-4.4/x86-speculation-fix-up-array_index_nospec_mask-asm-constraint.patch
queue-4.4/x86-bugs-remove-x86_spec_ctrl_set.patch
queue-4.4/x86-speculation-add-asm-msr-index.h-dependency.patch
queue-4.4/x86-cpu-intel-add-knights-mill-to-intel-family.patch
queue-4.4/x86-bugs-concentrate-bug-detection-into-a-separate-function.patch
queue-4.4/x86-bugs-fix-the-parameters-alignment-and-missing-void.patch
queue-4.4/x86-bugs-whitelist-allowed-spec_ctrl-msr-values.patch
queue-4.4/prctl-add-force-disable-speculation.patch
queue-4.4/x86-cpufeatures-add-intel-feature-bits-for-speculation-control.patch
queue-4.4/x86-speculation-use-synthetic-bits-for-ibrs-ibpb-stibp.patch
queue-4.4/x86-cpuid-fix-up-virtual-ibrs-ibpb-stibp-feature-bits-on-intel.patch
queue-4.4/x86-nospec-simplify-alternative_msr_write.patch
queue-4.4/x86-bugs-intel-set-proper-cpu-features-and-setup-rds.patch
queue-4.4/x86-speculation-use-indirect-branch-prediction-barrier-in-context-switch.patch
queue-4.4/x86-process-correct-and-optimize-tif_blockstep-switch.patch
queue-4.4/x86-speculation-use-ibrs-if-available-before-calling-into-firmware.patch
queue-4.4/x86-speculation-rework-speculative_store_bypass_update.patch
queue-4.4/x86-asm-entry-32-simplify-pushes-of-zeroed-pt_regs-regs.patch
queue-4.4/x86-bugs-make-cpu_show_common-static.patch
queue-4.4/seccomp-use-pr_spec_force_disable.patch
queue-4.4/x86-cpufeatures-disentangle-ssbd-enumeration.patch
queue-4.4/x86-cpu-amd-fix-erratum-1076-cpb-bit.patch
queue-4.4/x86-speculation-correct-speculation-control-microcode-blacklist-again.patch
queue-4.4/x86-cpu-rename-merrifield2-to-moorefield.patch
queue-4.4/x86-cpu-make-alternative_msr_write-work-for-32-bit-code.patch
queue-4.4/x86-cpufeatures-disentangle-msr_spec_ctrl-enumeration-from-ibrs.patch
queue-4.4/x86-cpufeatures-add-cpuid_7_edx-cpuid-leaf.patch
queue-4.4/x86-bugs-fix-__ssb_select_mitigation-return-type.patch
queue-4.4/x86-cpufeatures-add-feature_zen.patch
queue-4.4/xen-set-cpu-capabilities-from-xen_start_kernel.patch
queue-4.4/x86-bugs-rename-ssbd_no-to-ssb_no.patch
queue-4.4/x86-speculation-add-prctl-for-speculative-store-bypass-mitigation.patch
queue-4.4/x86-msr-add-definitions-for-new-speculation-control-msrs.patch
queue-4.4/seccomp-enable-speculation-flaw-mitigations.patch
queue-4.4/x86-spectre_v2-don-t-check-microcode-versions-when-running-under-hypervisors.patch
queue-4.4/selftest-seccomp-fix-the-seccomp-2-signature.patch
queue-4.4/proc-use-underscores-for-ssbd-in-status.patch
queue-4.4/x86-bugs-amd-add-support-to-disable-rds-on-famh-if-requested.patch
queue-4.4/x86-cpufeature-blacklist-spec_ctrl-pred_cmd-on-early-spectre-v2-microcodes.patch
queue-4.4/x86-bugs-rework-spec_ctrl-base-and-mask-logic.patch
queue-4.4/seccomp-add-filter-flag-to-opt-out-of-ssb-mitigation.patch
queue-4.4/x86-speculation-make-seccomp-the-default-mode-for-speculative-store-bypass.patch
queue-4.4/x86-bugs-kvm-support-the-combination-of-guest-and-host-ibrs.patch
queue-4.4/selftest-seccomp-fix-the-flag-name-seccomp_filter_flag_tsync.patch
queue-4.4/x86-mm-factor-out-ldt-init-from-context-init.patch
queue-4.4/x86-speculation-create-spec-ctrl.h-to-avoid-include-hell.patch
queue-4.4/x86-cpufeatures-clean-up-spectre-v2-related-cpuid-flags.patch
queue-4.4/x86-bugs-expose-sys-..-spec_store_bypass.patch
queue-4.4/nospec-allow-getting-setting-on-non-current-task.patch
queue-4.4/x86-speculation-clean-up-various-spectre-related-details.patch
queue-4.4/x86-bugs-concentrate-bug-reporting-into-a-separate-function.patch
queue-4.4/x86-pti-mark-constant-arrays-as-__initconst.patch
queue-4.4/x86-cpufeatures-add-amd-feature-bits-for-speculation-control.patch
queue-4.4/x86-pti-do-not-enable-pti-on-cpus-which-are-not-vulnerable-to-meltdown.patch
queue-4.4/x86-mm-give-each-mm-tlb-flush-generation-a-unique-id.patch
queue-4.4/seccomp-move-speculation-migitation-control-to-arch-code.patch
queue-4.4/x86-speculation-move-firmware_restrict_branch_speculation_-from-c-to-cpp.patch
queue-4.4/x86-xen-zero-msr_ia32_spec_ctrl-before-suspend.patch
queue-4.4/x86-amd-don-t-set-x86_bug_sysret_ss_attrs-when-running-under-xen.patch
queue-4.4/x86-bugs-kvm-extend-speculation-control-for-virt_spec_ctrl.patch
queue-4.4/prctl-add-speculation-control-prctls.patch
queue-4.4/x86-process-optimize-tif_notsc-switch.patch
queue-4.4/x86-process-allow-runtime-control-of-speculative-store-bypass.patch
queue-4.4/x86-bugs-unify-x86_spec_ctrl_-set_guest-restore_host.patch
queue-4.4/x86-bugs-expose-x86_spec_ctrl_base-directly.patch
queue-4.4/x86-bugs-provide-boot-parameters-for-the-spec_store_bypass_disable-mitigation.patch
queue-4.4/x86-speculation-update-speculation-control-microcode-blacklist.patch
queue-4.4/proc-provide-details-on-speculation-flaw-mitigations.patch
queue-4.4/x86-speculation-add-basic-ibpb-indirect-branch-prediction-barrier-support.patch
queue-4.4/x86-speculation-kvm-implement-support-for-virt_spec_ctrl-ls_cfg.patch
queue-4.4/x86-entry-64-compat-clear-registers-for-compat-syscalls-to-reduce-speculation-attack-surface.patch
queue-4.4/x86-process-optimize-tif-checks-in-__switch_to_xtra.patch
queue-4.4/x86-speculation-add-virtualized-speculative-store-bypass-disable-support.patch
queue-4.4/x86-bugs-read-spec_ctrl-msr-during-boot-and-re-use-reserved-bits.patch
