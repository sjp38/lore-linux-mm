Subject: Re: 2.6.0-test11-mm1
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <20031217035246.32adbf87.akpm@osdl.org>
References: <20031217014350.028460b2.akpm@osdl.org>
	 <20031217035246.32adbf87.akpm@osdl.org>
Content-Type: multipart/mixed; boundary="=-IlfhZDU4nFj9LviihjCj"
Message-Id: <1071667814.2588.0.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: Wed, 17 Dec 2003 14:30:14 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-IlfhZDU4nFj9LviihjCj
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2003-12-17 at 12:52, Andrew Morton wrote:

> And new breakage too!

> Fix:
> 
> 
> diff -puN arch/i386/kernel/cpu/intel.c~cpu_sibling_map-fixes-fix arch/i386/kernel/cpu/intel.c
> --- 25/arch/i386/kernel/cpu/intel.c~cpu_sibling_map-fixes-fix	2003-12-17 03:31:56.000000000 -0800
> +++ 25-akpm/arch/i386/kernel/cpu/intel.c	2003-12-17 03:46:25.000000000 -0800
> @@ -8,9 +8,11 @@
>  #include <asm/processor.h>
>  #include <asm/msr.h>
>  #include <asm/uaccess.h>
> +#include <asm/mpspec.h>
> +#include <asm/apic.h>
>  
>  #include "cpu.h"
> -#include "mach_apic.h"
> +#include <mach_apic.h>
>  
>  extern int trap_init_f00f_bug(void);

Does not apply cleanly, but this one does.

--=-IlfhZDU4nFj9LviihjCj
Content-Disposition: attachment; filename=intel.c~cpu_sibling_map-fixes-fix
Content-Type: text/x-patch; name=intel.c~cpu_sibling_map-fixes-fix; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -uNr linux-2.6.0-test11/arch/i386/kernel/cpu/intel.c linux-2.6.0-test11-mm1/arch/i386/kernel/cpu/intel.c
--- linux-2.6.0-test11/arch/i386/kernel/cpu/intel.c	2003-12-17 14:21:29.060115753 +0100
+++ linux-2.6.0-test11-mm1/arch/i386/kernel/cpu/intel.c	2003-12-17 14:10:39.886919748 +0100
@@ -9,9 +9,11 @@
 #include <asm/msr.h>
 #include <asm/uaccess.h>
 #include <asm/desc.h>
+#include <asm/mpspec.h>
+#include <asm/apic.h>
 
 #include "cpu.h"
-#include "mach_apic.h"
+#include <mach_apic.h>
 
 #ifdef CONFIG_X86_INTEL_USERCOPY
 /*

--=-IlfhZDU4nFj9LviihjCj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
