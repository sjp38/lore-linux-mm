Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 8EE186B0169
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:05:16 -0400 (EDT)
Date: Thu, 13 Sep 2012 12:05:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE
Message-Id: <20120913120514.135d2c38.akpm@linux-foundation.org>
In-Reply-To: <1347382036-18455-4-git-send-email-will.deacon@arm.com>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
	<1347382036-18455-4-git-send-email-will.deacon@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Tue, 11 Sep 2012 17:47:16 +0100
Will Deacon <will.deacon@arm.com> wrote:

> From: Steve Capper <steve.capper@arm.com>
> 
> Different architectures have slightly different pre-requisites for supporting
> Transparent Huge Pages. To simplify the layout of mm/Kconfig, a new option
> HAVE_ARCH_TRANSPARENT_HUGEPAGE is introduced and set in each architecture's
> Kconfig file (at the moment x86, with ARM being set in a future patch).
> 
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1297,6 +1297,10 @@ config ILLEGAL_POINTER_VALUE
>         default 0 if X86_32
>         default 0xdead000000000000 if X86_64
>  
> +config HAVE_ARCH_TRANSPARENT_HUGEPAGE
> +       def_bool y
> +       depends on MMU
> +
>  source "mm/Kconfig"
>  
>  config HIGHPTE
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d5c8019..3322342 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -318,7 +318,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
>  
>  config TRANSPARENT_HUGEPAGE
>  	bool "Transparent Hugepage Support"
> -	depends on X86 && MMU
> +	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
>  	select COMPACTION
>  	help
>  	  Transparent Hugepages allows the kernel to use huge pages and

We need to talk with Gerald concerning
http://ozlabs.org/~akpm/mmotm/broken-out/thp-x86-introduce-have_arch_transparent_hugepage.patch


I did this.  Please check.

From: Steve Capper <steve.capper@arm.com>
Subject: mm: introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE

Different architectures have slightly different pre-requisites for
supporting Transparent Huge Pages.  To simplify the layout of mm/Kconfig,
a new option HAVE_ARCH_TRANSPARENT_HUGEPAGE is introduced and set in each
architecture's Kconfig file (at the moment x86, with ARM being set in a
future patch).

Signed-off-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/Kconfig |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN arch/x86/Kconfig~mm-introduce-have_arch_transparent_hugepage arch/x86/Kconfig
--- a/arch/x86/Kconfig~mm-introduce-have_arch_transparent_hugepage
+++ a/arch/x86/Kconfig
@@ -83,7 +83,6 @@ config X86
 	select IRQ_FORCED_THREADING
 	select USE_GENERIC_SMP_HELPERS if SMP
 	select HAVE_BPF_JIT if X86_64
-	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
@@ -1330,6 +1329,10 @@ config ILLEGAL_POINTER_VALUE
        default 0 if X86_32
        default 0xdead000000000000 if X86_64
 
+config HAVE_ARCH_TRANSPARENT_HUGEPAGE
+       def_bool y
+       depends on MMU
+
 source "mm/Kconfig"
 
 config HIGHPTE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
