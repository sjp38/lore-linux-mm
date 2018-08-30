Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38DE16B5303
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:38:27 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w23-v6so5570127pgv.1
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:38:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u19-v6si7599308pgl.94.2018.08.30.12.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 Aug 2018 12:38:26 -0700 (PDT)
Subject: Re: [RFC PATCH v3 1/8] x86/cet/ibt: Add Kconfig option for user-mode
 Indirect Branch Tracking
References: <20180830144009.3314-1-yu-cheng.yu@intel.com>
 <20180830144009.3314-2-yu-cheng.yu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <cb30d63a-3eb9-a713-7129-6823a6d799cf@infradead.org>
Date: Thu, 30 Aug 2018 12:38:06 -0700
MIME-Version: 1.0
In-Reply-To: <20180830144009.3314-2-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 08/30/2018 07:40 AM, Yu-cheng Yu wrote:
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 2cfe11e1cf7f..0d97b03f35f6 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1941,6 +1941,18 @@ config X86_INTEL_SHADOW_STACK_USER
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
> +	  Indirect Branch Tracking provides hardware protection against return-/jmp-
> +	  oriented programing attacks.

	           programming

> +
> +	  If unsure, say y
> +
>  config EFI
>  	bool "EFI runtime service support"
>  	depends on ACPI


-- 
~Randy
