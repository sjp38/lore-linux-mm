Date: Wed, 17 Dec 2003 03:52:46 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test11-mm1
Message-Id: <20031217035246.32adbf87.akpm@osdl.org>
In-Reply-To: <20031217014350.028460b2.akpm@osdl.org>
References: <20031217014350.028460b2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test11/2.6.0-test11-mm1/
> 
> 
>  A fair number of new fixes

And new breakage too!


In file included from arch/i386/kernel/cpu/intel.c:14:
include/asm-i386/mach-default/mach_apic.h:8: error: syntax error before "target_cpus"
include/asm-i386/mach-default/mach_apic.h:9: warning: return type defaults to `int'


Fix:


diff -puN arch/i386/kernel/cpu/intel.c~cpu_sibling_map-fixes-fix arch/i386/kernel/cpu/intel.c
--- 25/arch/i386/kernel/cpu/intel.c~cpu_sibling_map-fixes-fix	2003-12-17 03:31:56.000000000 -0800
+++ 25-akpm/arch/i386/kernel/cpu/intel.c	2003-12-17 03:46:25.000000000 -0800
@@ -8,9 +8,11 @@
 #include <asm/processor.h>
 #include <asm/msr.h>
 #include <asm/uaccess.h>
+#include <asm/mpspec.h>
+#include <asm/apic.h>
 
 #include "cpu.h"
-#include "mach_apic.h"
+#include <mach_apic.h>
 
 extern int trap_init_f00f_bug(void);
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
