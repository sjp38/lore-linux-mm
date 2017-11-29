Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55DA36B025E
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:35:56 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id u4so2689608iti.2
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:35:56 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 70si1384827ity.52.2017.11.29.02.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 02:35:55 -0800 (PST)
Message-Id: <20171129103512.670195781@infradead.org>
Date: Wed, 29 Nov 2017 11:33:02 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 1/6] x86/mm/kaiser: Add some static
References: <20171129103301.131535445@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-moar-static.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

These fuctions are only used in this TU, make em static.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/mm/kaiser.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -260,8 +260,8 @@ static pte_t *kaiser_shadow_pagetable_wa
  * the user (shadow) page tables.  This may need to allocate page
  * table pages.
  */
-int kaiser_add_user_map(const void *__start_addr, unsigned long size,
-			unsigned long flags)
+static int kaiser_add_user_map(const void *__start_addr, unsigned long size,
+			       unsigned long flags)
 {
 	unsigned long start_addr = (unsigned long)__start_addr;
 	unsigned long address = start_addr & PAGE_MASK;
@@ -310,9 +310,9 @@ int kaiser_add_user_map(const void *__st
 	return 0;
 }
 
-int kaiser_add_user_map_ptrs(const void *__start_addr,
-			     const void *__end_addr,
-			     unsigned long flags)
+static int kaiser_add_user_map_ptrs(const void *__start_addr,
+				    const void *__end_addr,
+				    unsigned long flags)
 {
 	return kaiser_add_user_map(__start_addr,
 				   __end_addr - __start_addr,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
