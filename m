Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C09C76B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:19:58 -0500 (EST)
Received: by wmec201 with SMTP id c201so224825874wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:19:58 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id pk5si5844718wjb.102.2015.12.08.10.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:19:57 -0800 (PST)
Date: Tue, 8 Dec 2015 19:19:08 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 21/34] x86, pkeys: dump PKRU with other kernel
 registers
In-Reply-To: <20151204011453.007731D7@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081918060.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011453.007731D7@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I'm a bit ambivalent about whether this is needed or not.
>
> Protection Keys never affect kernel mappings.  But, they can
> affect whether the kernel will fault when it touches a user
> mapping.  But, the kernel doesn't touch user mappings without
> some careful choreography and these accesses don't generally
> result in oopses.

Well, if we miss some careful choreography at some place, this
information is going to be helpful.

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/arch/x86/kernel/process_64.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps arch/x86/kernel/process_64.c
> --- a/arch/x86/kernel/process_64.c~pkeys-30-kernel-error-dumps	2015-12-03 16:21:27.874773264 -0800
> +++ b/arch/x86/kernel/process_64.c	2015-12-03 16:21:27.877773400 -0800
> @@ -116,6 +116,8 @@ void __show_regs(struct pt_regs *regs, i
>  	printk(KERN_DEFAULT "DR0: %016lx DR1: %016lx DR2: %016lx\n", d0, d1, d2);
>  	printk(KERN_DEFAULT "DR3: %016lx DR6: %016lx DR7: %016lx\n", d3, d6, d7);
>  
> +	if (boot_cpu_has(X86_FEATURE_OSPKE))
> +		printk(KERN_DEFAULT "PKRU: %08x\n", read_pkru());
>  }
>  
>  void release_thread(struct task_struct *dead_task)
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
