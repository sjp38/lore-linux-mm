Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id ABAC66B00D8
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 13:40:31 -0400 (EDT)
Date: Tue, 11 Sep 2012 20:41:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE
Message-ID: <20120911174105.GB29805@shutemov.name>
References: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
 <1347382036-18455-4-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347382036-18455-4-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, Steve Capper <steve.capper@arm.com>

On Tue, Sep 11, 2012 at 05:47:16PM +0100, Will Deacon wrote:
> From: Steve Capper <steve.capper@arm.com>
> 
> Different architectures have slightly different pre-requisites for supporting
> Transparent Huge Pages. To simplify the layout of mm/Kconfig, a new option
> HAVE_ARCH_TRANSPARENT_HUGEPAGE is introduced and set in each architecture's
> Kconfig file (at the moment x86, with ARM being set in a future patch).
> 
> Signed-off-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>

> ---
>  arch/x86/Kconfig |    4 ++++
>  mm/Kconfig       |    2 +-
>  2 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 8ec3a1a..7decdcf 100644
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
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
