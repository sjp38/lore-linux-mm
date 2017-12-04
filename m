Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 391A26B027C
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:52:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e128so4385025wmg.1
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:52:38 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id e30si10645730wrc.555.2017.12.04.08.52.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:52:37 -0800 (PST)
Message-Id: <20171204150609.511885345@linutronix.de>
Date: Mon, 04 Dec 2017 15:08:03 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 57/60] x86/mm/kpti: Add Kconfig
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=x86-mm-kpti--Add_Kconfig.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

From: Dave Hansen <dave.hansen@linux.intel.com>

Finally allow CONFIG_KERNEL_PAGE_TABLE_ISOLATION to be enabled.

PARAVIRT generally requires that the kernel not manage its own page tables.
It also means that the hypervisor and kernel must agree wholeheartedly
about what format the page tables are in and what they contain.
KERNEL_PAGE_TABLE_ISOLATION, unfortunately, changes the rules and they
can not be used together.

I've seen conflicting feedback from maintainers lately about whether they
want the Kconfig magic to go first or last in a patch series.  It's going
last here because the partially-applied series leads to kernels that can
not boot in a bunch of cases.  I did a run through the entire series with
CONFIG_KERNEL_PAGE_TABLE_ISOLATION=y to look for build errors, though.

[ tglx: Removed SMP and !PARAVIRT dependencies as they not longer exist ]

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: keescook@google.com
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: moritz.lipp@iaik.tugraz.at
Cc: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: hughd@google.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: michael.schwarz@iaik.tugraz.at
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: richard.fellner@student.tugraz.at
Link: https://lkml.kernel.org/r/20171123003524.88C90659@viggo.jf.intel.com

---
 security/Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- a/security/Kconfig
+++ b/security/Kconfig
@@ -54,6 +54,16 @@ config SECURITY_NETWORK
 	  implement socket and networking access controls.
 	  If you are unsure how to answer this question, answer N.
 
+config KERNEL_PAGE_TABLE_ISOLATION
+	bool "Remove the kernel mapping in user mode"
+	depends on X86_64 && JUMP_LABEL
+	help
+	  This feature reduces the number of hardware side channels by
+	  ensuring that the majority of kernel addresses are not mapped
+	  into userspace.
+
+	  See Documentation/x86/pagetable-isolation.txt for more details.
+
 config SECURITY_INFINIBAND
 	bool "Infiniband Security Hooks"
 	depends on SECURITY && INFINIBAND


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
