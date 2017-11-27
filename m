Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A38CE6B025F
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:44:12 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y42so18898952wrd.23
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:44:12 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 107si19060340wrb.80.2017.11.27.12.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:44:11 -0800 (PST)
Message-Id: <20171127204257.654262031@linutronix.de>
Date: Mon, 27 Nov 2017 21:34:19 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 3/4] x86/mm/debug_pagetables: Use octal file permissions
References: <20171127203416.236563829@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm-debug_pagetables--Use-octal-file-permissions.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

As equested by several reviewers.

Fixes: ca646ac417b8 ("x86/mm/debug_pagetables: Allow dumping current pagetables")
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/mm/debug_pagetables.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -81,18 +81,18 @@ static void pt_dump_debug_remove_files(v
 
 static int __init pt_dump_debug_init(void)
 {
-	pe_knl = debugfs_create_file("kernel_page_tables", S_IRUSR, NULL, NULL,
+	pe_knl = debugfs_create_file("kernel_page_tables", 0400, NULL, NULL,
 				     &ptdump_fops);
 	if (!pe_knl)
 		return -ENOMEM;
 
-	pe_curknl = debugfs_create_file("current_page_tables_knl", S_IRUSR,
+	pe_curknl = debugfs_create_file("current_page_tables_knl", 0400,
 					NULL, NULL, &ptdump_curknl_fops);
 	if (!pe_curknl)
 		goto err;
 
 #ifdef CONFIG_KAISER
-	pe_curusr = debugfs_create_file("current_page_tables_usr", S_IRUSR,
+	pe_curusr = debugfs_create_file("current_page_tables_usr", 0400,
 					NULL, NULL, &ptdump_curusr_fops);
 	if (!pe_curusr)
 		goto err;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
