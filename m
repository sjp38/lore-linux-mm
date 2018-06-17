Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 953D36B0276
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:49:17 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q19-v6so8231691plr.22
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:49:17 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b3-v6si10231001pgr.495.2018.06.17.04.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:49:16 -0700 (PDT)
Subject: Patch "x86/mpx/selftests: Adjust the self-test to fresh distros that export the MPX ABI" has been added to the 4.16-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:53 +0200
Message-ID: <152923463323863@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180514085908.GA12798@gmail.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shakeelb@google.com, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mpx/selftests: Adjust the self-test to fresh distros that export the MPX ABI

to the 4.16-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mpx-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-mpx-abi.patch
and it can be found in the queue-4.16 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:07:34 CEST 2018
From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 14 May 2018 10:59:08 +0200
Subject: x86/mpx/selftests: Adjust the self-test to fresh distros that export the MPX ABI

From: Ingo Molnar <mingo@kernel.org>

[ Upstream commit 73bb4d6cd192b8629c5125aaada9892d9fc986b6 ]

Fix this warning:

  mpx-mini-test.c:422:0: warning: "SEGV_BNDERR" redefined

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: akpm@linux-foundation.org
Cc: dave.hansen@intel.com
Cc: linux-mm@kvack.org
Cc: linuxram@us.ibm.com
Cc: mpe@ellerman.id.au
Cc: shakeelb@google.com
Cc: shuah@kernel.org
Link: http://lkml.kernel.org/r/20180514085908.GA12798@gmail.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/mpx-mini-test.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- a/tools/testing/selftests/x86/mpx-mini-test.c
+++ b/tools/testing/selftests/x86/mpx-mini-test.c
@@ -368,6 +368,11 @@ static int expected_bnd_index = -1;
 uint64_t shadow_plb[NR_MPX_BOUNDS_REGISTERS][2]; /* shadow MPX bound registers */
 unsigned long shadow_map[NR_MPX_BOUNDS_REGISTERS];
 
+/* Failed address bound checks: */
+#ifndef SEGV_BNDERR
+# define SEGV_BNDERR	3
+#endif
+
 /*
  * The kernel is supposed to provide some information about the bounds
  * exception in the siginfo.  It should match what we have in the bounds
@@ -419,8 +424,6 @@ void handler(int signum, siginfo_t *si,
 		br_count++;
 		dprintf1("#BR 0x%jx (total seen: %d)\n", status, br_count);
 
-#define SEGV_BNDERR     3  /* failed address bound checks */
-
 		dprintf2("Saw a #BR! status 0x%jx at %016lx br_reason: %jx\n",
 				status, ip, br_reason);
 		dprintf2("si_signo: %d\n", si->si_signo);


Patches currently in stable-queue which might be from mingo@kernel.org are

queue-4.16/locking-rwsem-add-a-new-rwsem_anonymously_owned-flag.patch
queue-4.16/x86-pkeys-selftests-factor-out-instruction-page.patch
queue-4.16/kthread-sched-wait-fix-kthread_parkme-wait-loop.patch
queue-4.16/proc-kcore-don-t-bounds-check-against-address-0.patch
queue-4.16/stop_machine-sched-fix-migrate_swap-vs.-active_balance-deadlock.patch
queue-4.16/kthread-sched-wait-fix-kthread_parkme-completion-issue.patch
queue-4.16/init-fix-false-positives-in-w-x-checking.patch
queue-4.16/x86-pkeys-selftests-fix-pointer-math.patch
queue-4.16/x86-pkeys-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-pkeys-abi.patch
queue-4.16/locking-percpu-rwsem-annotate-rwsem-ownership-transfer-by-setting-rwsem_owner_unknown.patch
queue-4.16/x86-pkeys-selftests-add-a-test-for-pkey-0.patch
queue-4.16/x86-pkeys-selftests-stop-using-assert.patch
queue-4.16/sched-core-introduce-set_special_state.patch
queue-4.16/x86-pkeys-selftests-save-off-prot-for-allocations.patch
queue-4.16/x86-pkeys-selftests-remove-dead-debugging-code-fix-dprint_in_signal.patch
queue-4.16/x86-selftests-add-mov_to_ss-test.patch
queue-4.16/sched-debug-move-the-print_rt_rq-and-print_dl_rq-declarations-to-kernel-sched-sched.h.patch
queue-4.16/x86-mpx-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-mpx-abi.patch
queue-4.16/x86-pkeys-selftests-add-prot_exec-test.patch
queue-4.16/sched-deadline-make-the-grub_reclaim-function-static.patch
queue-4.16/objtool-kprobes-x86-sync-the-latest-asm-insn.h-header-with-tools-objtool-arch-x86-include-asm-insn.h.patch
queue-4.16/x86-pkeys-selftests-allow-faults-on-unknown-keys.patch
queue-4.16/x86-pkeys-selftests-give-better-unexpected-fault-error-messages.patch
queue-4.16/x86-pkeys-selftests-avoid-printf-in-signal-deadlocks.patch
queue-4.16/efi-libstub-arm64-handle-randomized-text_offset.patch
queue-4.16/x86-pkeys-selftests-fix-pkey-exhaustion-test-off-by-one.patch
