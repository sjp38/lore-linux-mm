Message-Id: <20080326014138.134849000@polaris-admin.engr.sgi.com>
References: <20080326014137.934171000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:41:38 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/2] boot: increase stack size for kernel boot loader decompressor
Content-Disposition: inline; filename=compressed-head_64
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Increase stack size for the kernel bootloader decompressor.  This is
needed to boot a kernel with NR_CPUS = 4096.  I tested with 8k stack
size but that wasn't sufficient.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/boot/compressed/head_64.S |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.25-rc5.orig/arch/x86/boot/compressed/head_64.S
+++ linux-2.6.25-rc5/arch/x86/boot/compressed/head_64.S
@@ -314,5 +314,5 @@ gdt_end:
 /* Stack for uncompression */
 	.balign 4
 user_stack:
-	.fill 4096,4,0
+	.fill 16384,4,0
 user_stack_end:

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
