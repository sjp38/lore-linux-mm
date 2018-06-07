Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4926B026C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:44:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 76-v6so4932607wmw.3
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:44:23 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k6-v6si13884300wrr.333.2018.06.07.09.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Jun 2018 09:44:22 -0700 (PDT)
Subject: Re: [PATCH 1/7] x86/cet: Add Kconfig option for user-mode Indirect
 Branch Tracking
References: <20180607143855.3681-1-yu-cheng.yu@intel.com>
 <20180607143855.3681-2-yu-cheng.yu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9c99f892-8965-8b08-4a80-506b48c2205d@infradead.org>
Date: Thu, 7 Jun 2018 09:43:49 -0700
MIME-Version: 1.0
In-Reply-To: <20180607143855.3681-2-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On 06/07/2018 07:38 AM, Yu-cheng Yu wrote:
> The user-mode indirect branch tracking support is done mostly by
> GCC to insert ENDBR64/ENDBR32 instructions at branch targets.
> The kernel provides CPUID enumeration, feature MSR setup and
> the allocation of legacy bitmap.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/Kconfig | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 24339a5299da..27bfbd137fbe 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1953,6 +1953,18 @@ config X86_INTEL_SHADOW_STACK_USER
>  
>  	  If unsure, say y.
>  
> +config X86_INTEL_BRANCH_TRACKING_USER
> +	prompt "Intel Indirect Branch Tracking for user-mode"
> +	def_bool n
> +	depends on CPU_SUP_INTEL && X86_64
> +	select X86_INTEL_CET
> +	select ARCH_HAS_PROGRAM_PROPERTIES
> +	---help---
> +	  Indirect Branch Tracking provides hardware protection against 	
> +	  oriented programing attacks.

	           programming

and please just move the return/jmp parts to the next line also:

	                                             protection against
	  return-/jmp-oriented programming attacks.

> +
> +	  If unsure, say y
> +
>  config EFI
>  	bool "EFI runtime service support"
>  	depends on ACPI
> 


-- 
~Randy
