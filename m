Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E21346B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 02:21:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c28-v6so15525412pfe.4
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 23:21:44 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id 17-v6si19775197pgz.577.2018.10.17.23.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 23:21:43 -0700 (PDT)
Date: Wed, 17 Oct 2018 23:21:15 -0700
From: tip-bot for Jan Kiszka <tipbot@zytor.com>
Message-ID: <tip-04f4f954b69526d7af8ffb8e5780f08b8a6cda2d@git.kernel.org>
Reply-To: jgross@suse.com, jpoimboe@redhat.com, jkosina@suse.cz,
        x86@kernel.org, gregkh@linuxfoundation.org, luto@kernel.org,
        mingo@kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com,
        jroedel@suse.de, hpa@zytor.com, dvlasenk@redhat.com,
        boris.ostrovsky@oracle.com, torvalds@linux-foundation.org,
        linux-mm@kvack.org, dave.hansen@intel.com, jan.kiszka@siemens.com,
        eduval@amazon.com, bp@suse.de, will.deacon@arm.com, tglx@linutronix.de,
        David.Laight@aculab.com, brgerst@gmail.com, peterz@infradead.org
In-Reply-To: <f271c747-1714-5a5b-a71f-ae189a093b8d@siemens.com>
References: <f271c747-1714-5a5b-a71f-ae189a093b8d@siemens.com>
Subject: [tip:x86/urgent] x86/entry/32: Clear the CS high bits
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: jkosina@suse.cz, jpoimboe@redhat.com, x86@kernel.org, jgross@suse.com, aarcange@redhat.com, linux-kernel@vger.kernel.org, jroedel@suse.de, gregkh@linuxfoundation.org, mingo@kernel.org, luto@kernel.org, boris.ostrovsky@oracle.com, linux-mm@kvack.org, torvalds@linux-foundation.org, dave.hansen@intel.com, jan.kiszka@siemens.com, eduval@amazon.com, hpa@zytor.com, dvlasenk@redhat.com, tglx@linutronix.de, brgerst@gmail.com, David.Laight@aculab.com, peterz@infradead.org, bp@suse.de, will.deacon@arm.com

Commit-ID:  04f4f954b69526d7af8ffb8e5780f08b8a6cda2d
Gitweb:     https://git.kernel.org/tip/04f4f954b69526d7af8ffb8e5780f08b8a6cda2d
Author:     Jan Kiszka <jan.kiszka@siemens.com>
AuthorDate: Mon, 15 Oct 2018 16:09:29 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Wed, 17 Oct 2018 12:30:20 +0200

x86/entry/32: Clear the CS high bits

Even if not on an entry stack, the CS's high bits must be
initialized because they are unconditionally evaluated in
PARANOID_EXIT_TO_KERNEL_MODE.

Failing to do so broke the boot on Galileo Gen2 and IOT2000 boards.

 [ bp: Make the commit message tone passive and impartial. ]

Fixes: b92a165df17e ("x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack")
Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Joerg Roedel <jroedel@suse.de>
Acked-by: Joerg Roedel <jroedel@suse.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: Andy Lutomirski <luto@kernel.org>
CC: Boris Ostrovsky <boris.ostrovsky@oracle.com>
CC: Brian Gerst <brgerst@gmail.com>
CC: Dave Hansen <dave.hansen@intel.com>
CC: David Laight <David.Laight@aculab.com>
CC: Denys Vlasenko <dvlasenk@redhat.com>
CC: Eduardo Valentin <eduval@amazon.com>
CC: Greg KH <gregkh@linuxfoundation.org>
CC: Ingo Molnar <mingo@kernel.org>
CC: Jiri Kosina <jkosina@suse.cz>
CC: Josh Poimboeuf <jpoimboe@redhat.com>
CC: Juergen Gross <jgross@suse.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Will Deacon <will.deacon@arm.com>
CC: aliguori@amazon.com
CC: daniel.gruss@iaik.tugraz.at
CC: hughd@google.com
CC: keescook@google.com
CC: linux-mm <linux-mm@kvack.org>
CC: x86-ml <x86@kernel.org>
Link: http://lkml.kernel.org/r/f271c747-1714-5a5b-a71f-ae189a093b8d@siemens.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/entry/entry_32.S | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 2767c625a52c..fbbf1ba57ec6 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -389,6 +389,13 @@
 	 * that register for the time this macro runs
 	 */
 
+	/*
+	 * The high bits of the CS dword (__csh) are used for
+	 * CS_FROM_ENTRY_STACK and CS_FROM_USER_CR3. Clear them in case
+	 * hardware didn't do this for us.
+	 */
+	andl	$(0x0000ffff), PT_CS(%esp)
+
 	/* Are we on the entry stack? Bail out if not! */
 	movl	PER_CPU_VAR(cpu_entry_area), %ecx
 	addl	$CPU_ENTRY_AREA_entry_stack + SIZEOF_entry_stack, %ecx
@@ -407,12 +414,6 @@
 	/* Load top of task-stack into %edi */
 	movl	TSS_entry2task_stack(%edi), %edi
 
-	/*
-	 * Clear unused upper bits of the dword containing the word-sized CS
-	 * slot in pt_regs in case hardware didn't clear it for us.
-	 */
-	andl	$(0x0000ffff), PT_CS(%esp)
-
 	/* Special case - entry from kernel mode via entry stack */
 #ifdef CONFIG_VM86
 	movl	PT_EFLAGS(%esp), %ecx		# mix EFLAGS and CS
