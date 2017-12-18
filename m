Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6D596B027B
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:56:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b82so6819715wmd.5
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:56:12 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n22si1602861wrn.262.2017.12.18.03.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 03:56:11 -0800 (PST)
Message-Id: <20171218115257.491046318@linutronix.de>
Date: Mon, 18 Dec 2017 12:43:02 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V163 47/51] x86/mm/pti: Add Kconfig
References: <20171218114215.239543034@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=0056-x86-mm-pti-Add-Kconfig.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

Finally allow CONFIG_PAGE_TABLE_ISOLATION to be enabled.

PARAVIRT generally requires that the kernel not manage its own page tables.
It also means that the hypervisor and kernel must agree wholeheartedly
about what format the page tables are in and what they contain.
PAGE_TABLE_ISOLATION, unfortunately, changes the rules and they
can not be used together.

I've seen conflicting feedback from maintainers lately about whether they
want the Kconfig magic to go first or last in a patch series.  It's going
last here because the partially-applied series leads to kernels that can
not boot in a bunch of cases.  I did a run through the entire series with
CONFIG_PAGE_TABLE_ISOLATION=y to look for build errors, though.

[ tglx: Removed SMP and !PARAVIRT dependencies as they not longer exist ]

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 security/Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- a/security/Kconfig
+++ b/security/Kconfig
@@ -54,6 +54,16 @@ config SECURITY_NETWORK
 	  implement socket and networking access controls.
 	  If you are unsure how to answer this question, answer N.
 
+config PAGE_TABLE_ISOLATION
+	bool "Remove the kernel mapping in user mode"
+	depends on X86_64 && !UML
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
