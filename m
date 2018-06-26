Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7BD6B029B
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:30:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x25-v6so9055775pfn.21
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:30:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k184-v6si1757574pge.209.2018.06.26.10.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Jun 2018 10:30:15 -0700 (PDT)
Subject: Re: [PATCHv4 18/18] x86: Introduce CONFIG_X86_INTEL_MKTME
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <ecf92475-93b4-295c-f1fc-7efba4843d98@infradead.org>
Date: Tue, 26 Jun 2018 10:30:12 -0700
MIME-Version: 1.0
In-Reply-To: <20180626142245.82850-19-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/26/2018 07:22 AM, Kirill A. Shutemov wrote:
> Add new config option to enabled/disable Multi-Key Total Memory
> Encryption support.
> 
> MKTME uses MEMORY_PHYSICAL_PADDING to reserve enough space in per-KeyID
> direct mappings for memory hotplug.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/Kconfig | 19 ++++++++++++++++++-
>  1 file changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index fa5e1ec09247..9a843bd63108 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1523,6 +1523,23 @@ config ARCH_USE_MEMREMAP_PROT
>  	def_bool y
>  	depends on AMD_MEM_ENCRYPT
>  
> +config X86_INTEL_MKTME
> +	bool "Intel Multi-Key Total Memory Encryption"
> +	select DYNAMIC_PHYSICAL_MASK
> +	select PAGE_EXTENSION
> +	depends on X86_64 && CPU_SUP_INTEL
> +	---help---
> +	  Say yes to enable support for Multi-Key Total Memory Encryption.
> +	  This requires an Intel processor that has support of the feature.
> +
> +	  Multikey Total Memory Encryption (MKTME) is a technology that allows
> +	  transparent memory encryption in and upcoming Intel platforms.

huh?  Maybe drop the "and"?

> +
> +	  MKTME is built on top of TME. TME allows encryption of the entirety
> +	  of system memory using a single key. MKTME allows having multiple
> +	  encryption domains, each having own key -- different memory pages can
> +	  be encrypted with different keys.
> +
>  # Common NUMA Features
>  config NUMA
>  	bool "Numa Memory Allocation and Scheduler Support"
> @@ -2199,7 +2216,7 @@ config RANDOMIZE_MEMORY
>  
>  config MEMORY_PHYSICAL_PADDING
>  	hex "Physical memory mapping padding" if EXPERT
> -	depends on RANDOMIZE_MEMORY
> +	depends on RANDOMIZE_MEMORY || X86_INTEL_MKTME
>  	default "0xa" if MEMORY_HOTPLUG
>  	default "0x0"
>  	range 0x1 0x40 if MEMORY_HOTPLUG
> 


-- 
~Randy
