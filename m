Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 42603440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:29:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id q127so3566757wmd.1
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:29:31 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id l10si5410244wrf.26.2017.11.09.02.29.30
        for <linux-mm@kvack.org>;
        Thu, 09 Nov 2017 02:29:30 -0800 (PST)
Date: Thu, 9 Nov 2017 11:29:25 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/30] x86, mm: do not set _PAGE_USER for init_mm page
 tables
Message-ID: <20171109102925.xrk4yfq642zw4yls@pd.tnic>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194647.ABC9BC79@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171108194647.ABC9BC79@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Wed, Nov 08, 2017 at 11:46:47AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> init_mm is for kernel-exclusive use.  If someone is allocating page
> tables for it, do not set _PAGE_USER on them.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> ---
> 
>  b/arch/x86/include/asm/pgalloc.h |   33 ++++++++++++++++++++++++++++-----
>  1 file changed, 28 insertions(+), 5 deletions(-)
> 
> diff -puN arch/x86/include/asm/pgalloc.h~kaiser-prep-clear-_PAGE_USER-for-init_mm arch/x86/include/asm/pgalloc.h
> --- a/arch/x86/include/asm/pgalloc.h~kaiser-prep-clear-_PAGE_USER-for-init_mm	2017-11-08 10:45:25.928681403 -0800
> +++ b/arch/x86/include/asm/pgalloc.h	2017-11-08 10:45:25.931681403 -0800
> @@ -61,20 +61,37 @@ static inline void __pte_free_tlb(struct
>  	___pte_free_tlb(tlb, pte);
>  }
>  
> +/*
> + * init_mm is for kernel-exclusive use.  Any page tables that
> + * are seteup for it should not be usable by userspace.

s/seteup/setup/

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
