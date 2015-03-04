Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 64D656B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 18:31:15 -0500 (EST)
Received: by wivr20 with SMTP id r20so2880461wiv.5
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 15:31:14 -0800 (PST)
Received: from cpsmtpb-ews09.kpnxchange.com (cpsmtpb-ews09.kpnxchange.com. [213.75.39.14])
        by mx.google.com with ESMTP id ba2si10910934wib.73.2015.03.04.15.31.13
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 15:31:13 -0800 (PST)
Message-ID: <1425511871.2090.65.camel@tiscali.nl>
Subject: Re: [PATCH v3 6/6 UPDATE] x86, mm: Support huge KVA mappings on x86
From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 05 Mar 2015 00:31:11 +0100
In-Reply-To: <1425426480-10600-1-git-send-email-toshi.kani@hp.com>
References: <1425426480-10600-1-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com

Toshi Kani schreef op di 03-03-2015 om 16:48 [-0700]:
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -99,6 +99,7 @@ config X86
>  	select IRQ_FORCED_THREADING
>  	select HAVE_BPF_JIT if X86_64
>  	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
> +	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)

Minor nit: X86_PAE depends on X86_32, so I think this could be just
    select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE

>  	select ARCH_HAS_SG_CHAIN
>  	select CLKEVT_I8253
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
