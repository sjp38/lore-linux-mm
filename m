Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 941ED6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 08:12:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e8so101182474pfl.4
        for <linux-mm@kvack.org>; Mon, 15 May 2017 05:12:30 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a89si10570636pfg.237.2017.05.15.05.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 05:12:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5, REBASED 1/9] x86/asm: Fix comment in return_from_SYSCALL_64
Date: Mon, 15 May 2017 15:12:10 +0300
Message-Id: <20170515121218.27610-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On x86-64 __VIRTUAL_MASK_SHIFT depends on paging mode now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/entry/entry_64.S | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index 607d72c4a485..edec30584eb8 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -266,7 +266,8 @@ return_from_SYSCALL_64:
 	 * If width of "canonical tail" ever becomes variable, this will need
 	 * to be updated to remain correct on both old and new CPUs.
 	 *
-	 * Change top 16 bits to be the sign-extension of 47th bit
+	 * Change top bits to match most significant bit (47th or 56th bit
+	 * depending on paging mode) in the address.
 	 */
 	shl	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 	sar	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
