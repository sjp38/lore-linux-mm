Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id D037C6B025A
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:21:55 -0500 (EST)
Received: by wmec201 with SMTP id c201so224899168wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:21:55 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id xu5si5886161wjc.5.2015.12.08.10.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:21:54 -0800 (PST)
Date: Tue, 8 Dec 2015 19:21:05 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 23/34] x86, pkeys: add Kconfig prompt to existing config
 option
In-Reply-To: <20151204011456.A052855B@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081920250.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011456.A052855B@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> I don't have a strong opinion on whether we need this or not.
> Protection Keys has relatively little code associated with it,
> and it is not a heavyweight feature to keep enabled.  However,
> I can imagine that folks would still appreciate being able to
> disable it.

The tiny kernel folks are happy about every few kB which are NOT
added by default.
 
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

> ---
> 
>  b/arch/x86/Kconfig |   10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff -puN arch/x86/Kconfig~pkeys-40-kconfig-prompt arch/x86/Kconfig
> --- a/arch/x86/Kconfig~pkeys-40-kconfig-prompt	2015-12-03 16:21:28.726811905 -0800
> +++ b/arch/x86/Kconfig	2015-12-03 16:21:28.730812086 -0800
> @@ -1682,8 +1682,18 @@ config X86_INTEL_MPX
>  	  If unsure, say N.
>  
>  config X86_INTEL_MEMORY_PROTECTION_KEYS
> +	prompt "Intel Memory Protection Keys"
>  	def_bool y
> +	# Note: only available in 64-bit mode
>  	depends on CPU_SUP_INTEL && X86_64
> +	---help---
> +	  Memory Protection Keys provides a mechanism for enforcing
> +	  page-based protections, but without requiring modification of the
> +	  page tables when an application changes protection domains.
> +
> +	  For details, see Documentation/x86/protection-keys.txt
> +
> +	  If unsure, say y.
>  
>  config EFI
>  	bool "EFI runtime service support"
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
