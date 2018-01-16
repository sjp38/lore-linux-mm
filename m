Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9963B6B027C
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:36:04 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y18so7887484wrh.12
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:36:04 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r185si2220415wma.190.2018.01.16.10.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 10:36:02 -0800 (PST)
Date: Tue, 16 Jan 2018 19:35:51 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 01/16] x86/entry/32: Rename TSS_sysenter_sp0 to
 TSS_sysenter_stack
In-Reply-To: <1516120619-1159-2-git-send-email-joro@8bytes.org>
Message-ID: <alpine.DEB.2.20.1801161935130.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-2-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, 16 Jan 2018, Joerg Roedel wrote:

> From: Joerg Roedel <jroedel@suse.de>
> 
> The stack addresss doesn't need to be stored in tss.sp0 if
> we switch manually like on sysenter. Rename the offset so
> that it still makes sense when we its location.

-ENOSENTENCE

Other than that. Makes sense.

> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/entry/entry_32.S        | 2 +-
>  arch/x86/kernel/asm-offsets_32.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index a1f28a54f23a..eb8c5615777b 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -401,7 +401,7 @@ ENTRY(xen_sysenter_target)
>   * 0(%ebp) arg6
>   */
>  ENTRY(entry_SYSENTER_32)
> -	movl	TSS_sysenter_sp0(%esp), %esp
> +	movl	TSS_sysenter_stack(%esp), %esp
>  .Lsysenter_past_esp:
>  	pushl	$__USER_DS		/* pt_regs->ss */
>  	pushl	%ebp			/* pt_regs->sp (stashed in bp) */
> diff --git a/arch/x86/kernel/asm-offsets_32.c b/arch/x86/kernel/asm-offsets_32.c
> index fa1261eefa16..654229bac2fc 100644
> --- a/arch/x86/kernel/asm-offsets_32.c
> +++ b/arch/x86/kernel/asm-offsets_32.c
> @@ -47,7 +47,7 @@ void foo(void)
>  	BLANK();
>  
>  	/* Offset from the sysenter stack to tss.sp0 */
> -	DEFINE(TSS_sysenter_sp0, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
> +	DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
>  	       offsetofend(struct cpu_entry_area, entry_stack_page.stack));
>  
>  #ifdef CONFIG_CC_STACKPROTECTOR
> -- 
> 2.13.6
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
