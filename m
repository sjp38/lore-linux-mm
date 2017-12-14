Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 179A86B0261
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:42 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g69so7889220ita.9
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l16si2997862iti.23.2017.12.14.03.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:41 -0800 (PST)
Message-Id: <20171214113851.647809433@infradead.org>
Date: Thu, 14 Dec 2017 12:27:37 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 11/17] selftests/x86/ldt_gdt: Prepare for access bit forced
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=selftests-x86-ldt_gdt--Prepare-for-access-bit-forced.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

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
