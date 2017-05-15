Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 379896B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 08:31:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u187so109928640pgb.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 05:31:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8si10803877pli.303.2017.05.15.05.31.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 05:31:08 -0700 (PDT)
Subject: Re: [PATCHv5, REBASED 8/9] x86: Enable 5-level paging support
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
 <20170515121218.27610-9-kirill.shutemov@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <9af22de7-89f3-576a-f933-c4e593924091@suse.com>
Date: Mon, 15 May 2017 14:31:00 +0200
MIME-Version: 1.0
In-Reply-To: <20170515121218.27610-9-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15/05/17 14:12, Kirill A. Shutemov wrote:
> Most of things are in place and we can enable support of 5-level paging.
> 
> Enabling XEN with 5-level paging requires more work. The patch makes XEN
> dependent on !X86_5LEVEL.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/Kconfig     | 5 +++++
>  arch/x86/xen/Kconfig | 1 +
>  2 files changed, 6 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index cd18994a9555..11bd0498f64c 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -318,6 +318,7 @@ config FIX_EARLYCON_MEM
>  
>  config PGTABLE_LEVELS
>  	int
> +	default 5 if X86_5LEVEL
>  	default 4 if X86_64
>  	default 3 if X86_PAE
>  	default 2
> @@ -1390,6 +1391,10 @@ config X86_PAE
>  	  has the cost of more pagetable lookup overhead, and also
>  	  consumes more pagetable space per process.
>  
> +config X86_5LEVEL
> +	bool "Enable 5-level page tables support"
> +	depends on X86_64
> +
>  config ARCH_PHYS_ADDR_T_64BIT
>  	def_bool y
>  	depends on X86_64 || X86_PAE
> diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
> index 027987638e98..12205e6dfa59 100644
> --- a/arch/x86/xen/Kconfig
> +++ b/arch/x86/xen/Kconfig
> @@ -5,6 +5,7 @@
>  config XEN
>  	bool "Xen guest support"
>  	depends on PARAVIRT
> +	depends on !X86_5LEVEL

I'd rather put this under "config XEN_PV".


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
