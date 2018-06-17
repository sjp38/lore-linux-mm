Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 960A66B026F
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 07:36:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g15-v6so7122318pfh.10
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 04:36:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o2-v6si12196296pfh.327.2018.06.17.04.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 04:36:33 -0700 (PDT)
Subject: Patch "x86/pkeys/selftests: Remove dead debugging code, fix dprint_in_signal" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:23:31 +0200
Message-ID: <1529234611122103@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 20180509171342.846B9B2E@viggo.jf.intel.com, akpm@linux-foundation.org, alexander.levin@microsoft.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linuxram@us.ibm.com, mingo@kernel.org, mpe@ellerman.id.au, peterz@infradead.org, shuah@kernel.org, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/pkeys/selftests: Remove dead debugging code, fix dprint_in_signal

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-pkeys-selftests-remove-dead-debugging-code-fix-dprint_in_signal.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Sun Jun 17 12:13:49 CEST 2018
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 9 May 2018 10:13:42 -0700
Subject: x86/pkeys/selftests: Remove dead debugging code, fix dprint_in_signal

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit a50093d60464dd51d1ae0c2267b0abe9e1de77f3 ]

There is some noisy debug code at the end of the signal handler.  It was
disabled by an early, unconditional "return".  However, that return also
hid a dprint_in_signal=0, which kept dprint_in_signal=1 and effectively
locked us into permanent dprint_in_signal=1 behavior.

Remove the return and the dead code, fixing dprint_in_signal.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20180509171342.846B9B2E@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/protection_keys.c |   16 ----------------
 1 file changed, 16 deletions(-)

--- a/tools/testing/selftests/x86/protection_keys.c
+++ b/tools/testing/selftests/x86/protection_keys.c
@@ -325,22 +325,6 @@ void signal_handler(int signum, siginfo_
 	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
 	pkru_faults++;
 	dprintf1("<<<<==================================================\n");
-	return;
-	if (trapno == 14) {
-		fprintf(stderr,
-			"ERROR: In signal handler, page fault, trapno = %d, ip = %016lx\n",
-			trapno, ip);
-		fprintf(stderr, "si_addr %p\n", si->si_addr);
-		fprintf(stderr, "REG_ERR: %lx\n",
-				(unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
-		exit(1);
-	} else {
-		fprintf(stderr, "unexpected trap %d! at 0x%lx\n", trapno, ip);
-		fprintf(stderr, "si_addr %p\n", si->si_addr);
-		fprintf(stderr, "REG_ERR: %lx\n",
-				(unsigned long)uctxt->uc_mcontext.gregs[REG_ERR]);
-		exit(2);
-	}
 	dprint_in_signal = 0;
 }
 


Patches currently in stable-queue which might be from dave.hansen@linux.intel.com are

queue-4.14/x86-pkeys-selftests-factor-out-instruction-page.patch
queue-4.14/x86-pkeys-selftests-fix-pointer-math.patch
queue-4.14/x86-pkeys-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-pkeys-abi.patch
queue-4.14/x86-pkeys-selftests-add-a-test-for-pkey-0.patch
queue-4.14/x86-pkeys-selftests-stop-using-assert.patch
queue-4.14/x86-pkeys-selftests-save-off-prot-for-allocations.patch
queue-4.14/x86-pkeys-selftests-remove-dead-debugging-code-fix-dprint_in_signal.patch
queue-4.14/x86-mpx-selftests-adjust-the-self-test-to-fresh-distros-that-export-the-mpx-abi.patch
queue-4.14/x86-pkeys-selftests-add-prot_exec-test.patch
queue-4.14/x86-pkeys-selftests-allow-faults-on-unknown-keys.patch
queue-4.14/x86-pkeys-selftests-give-better-unexpected-fault-error-messages.patch
queue-4.14/x86-pkeys-selftests-fix-pkey-exhaustion-test-off-by-one.patch
