Date: Wed, 9 Jul 2003 04:24:33 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.5.74-mm3
Message-ID: <20030709092433.GA27280@waste.org>
References: <20030708223548.791247f5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030708223548.791247f5.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 08, 2003 at 10:35:48PM -0700, Andrew Morton wrote:
>  Merged
> 
> -cpumask_t-1.patch
> -gcc-bug-workaround.patch
> -sparse-apic-fix.patch
> -nuke-cpumask_arith.patch
> -p4-clockmod-cpumask-fix.patch
> 
>  Folded into cpumask_t-1.patch
> 
> +cpumask_t-s390-fix.patch
> +kgdb-cpumask_t.patch
> +cpumask_t-x86_64-fix.patch
> +sparc64-cpumask_t-fix.patch
> 
>  cpumask_t fixes

UP APM has broken since -mm2, looks like something like this is
needed (compiles, untested):

diff -urN -x genksyms -x '*.ver' -x '.patch*' -x '*.orig' orig/arch/i386/kernel/apm.c patched/arch/i386/kernel/apm.c
--- orig/arch/i386/kernel/apm.c	2003-07-09 04:07:06.000000000 -0500
+++ patched/arch/i386/kernel/apm.c	2003-07-09 04:19:52.000000000 -0500
@@ -528,7 +528,7 @@
  *	No CPU lockdown needed on a uniprocessor
  */
  
-#define apm_save_cpus()	0
+#define apm_save_cpus()	(current->cpus_allowed)
 #define apm_restore_cpus(x)	(void)(x)
 
 #endif

-- 
Matt Mackall : http://www.selenic.com : of or relating to the moon
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
