Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 730E46B026B
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a45so12676390wra.14
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:55 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c64si33906wmi.248.2017.12.12.09.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:54 -0800 (PST)
Message-Id: <20171212173333.923176982@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:29 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 08/16] selftests/x86/ldt_gdt: Prepare for access bit forced
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=selftests-x86-ldt_gdt--Prepare-for-access-bit-forced.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

In order to make the LDT mapping RO the access bit needs to be forced by
the kernel. Adjust the test case so it handles that gracefully.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 tools/testing/selftests/x86/ldt_gdt.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/tools/testing/selftests/x86/ldt_gdt.c
+++ b/tools/testing/selftests/x86/ldt_gdt.c
@@ -122,8 +122,7 @@ static void check_valid_segment(uint16_t
 	 * NB: Different Linux versions do different things with the
 	 * accessed bit in set_thread_area().
 	 */
-	if (ar != expected_ar &&
-	    (ldt || ar != (expected_ar | AR_ACCESSED))) {
+	if (ar != expected_ar && ar != (expected_ar | AR_ACCESSED)) {
 		printf("[FAIL]\t%s entry %hu has AR 0x%08X but expected 0x%08X\n",
 		       (ldt ? "LDT" : "GDT"), index, ar, expected_ar);
 		nerrs++;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
