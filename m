Message-Id: <20080509152246.109754763@saeurebad.de>
References: <20080509151713.939253437@saeurebad.de>
Date: Fri, 09 May 2008 17:17:16 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH 3/3] x86: Migrate X86_32 to bootmem2
Content-Disposition: inline; filename=migrate-x86_32-to-bootmem2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Straight-forward migration to bootmem2 for x86 single-node systems.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
 arch/x86/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -25,6 +25,7 @@
 	select HAVE_KRETPROBES
 	select HAVE_KVM if ((X86_32 && !X86_VOYAGER && !X86_VISWS && !X86_NUMAQ) || X86_64)
 	select HAVE_ARCH_KGDB if !X86_VOYAGER
+	select HAVE_BOOTMEM2 if X86_32
 
 config DEFCONFIG_LIST
 	string

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
