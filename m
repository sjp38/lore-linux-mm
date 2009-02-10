Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C72DA6B0047
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 09:14:13 -0500 (EST)
Date: Tue, 10 Feb 2009 15:14:05 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Using module private memory to simulate microkernel's memory
	protection
Message-ID: <20090210141405.GA16147@elte.hu>
References: <a5f59d880902100542x7243b13fuf40e7dd21faf7d7a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5f59d880902100542x7243b13fuf40e7dd21faf7d7a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pengfei Hu <hpfei.cn@gmail.com>, Vegard Nossum <vegard.nossum@gmail.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Pengfei Hu <hpfei.cn@gmail.com> wrote:

> diff -Nurp old/arch/x86/Kconfig.debug new/arch/x86/Kconfig.debug
> --- old/arch/x86/Kconfig.debug	2008-10-10 06:13:53.000000000 +0800
> +++ new/arch/x86/Kconfig.debug	2008-12-07 19:19:40.000000000 +0800
> @@ -67,6 +67,16 @@ config DEBUG_PAGEALLOC
>  	  This results in a large slowdown, but helps to find certain types
>  	  of memory corruptions.
> 
> +config DEBUG_KM_PROTECT
> +        bool "Debug kernel memory protect"
> +        depends on DEBUG_KERNEL
> +        select DEBUG_PAGEALLOC
> +        select SLUB
> +        help
> +          Change page table's present flag to prevent other module's accidental
> +          access. This results in a large slowdown and waste more memory, but
> +          helps to find certain types of memory corruptions.

Hm, are you aware of the kmemcheck project?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
