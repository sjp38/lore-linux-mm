Message-Id: <200601180127.k0I1R8g18386@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH/RFC] Shared page tables
Date: Tue, 17 Jan 2006 17:27:09 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060117235302.GA22451@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Robin Holt' <holt@sgi.com>, Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Robin Holt wrote on Tuesday, January 17, 2006 3:53 PM
> This appears to work on ia64 with the attached patch.  Could you
> send me any test application you think would be helpful for me
> to verify it is operating correctly?  I could not get the PTSHARE_PUD
> to compile.  I put _NO_ effort into it.  I found the following line
> was invalid and quit trying.
> 
> --- linux-2.6.orig/arch/ia64/Kconfig	2006-01-14 07:16:46.149226872 -0600
> +++ linux-2.6/arch/ia64/Kconfig	2006-01-14 07:25:02.228853432 -0600
> @@ -289,6 +289,38 @@ source "mm/Kconfig"
>  config ARCH_SELECT_MEMORY_MODEL
>  	def_bool y
>  
> +
> +config PTSHARE_HUGEPAGE
> +	bool
> +	depends on PTSHARE && PTSHARE_PMD
> +	default y
> +

You need to thread carefully with hugetlb ptshare on ia64. PTE for
hugetlb page on ia64 observe full page table levels, not like x86
that sits in the pmd level.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
