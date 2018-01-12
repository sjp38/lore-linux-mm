Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C91D06B0069
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 13:58:18 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r63so3440081wmb.9
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 10:58:18 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i16si2657358wmc.159.2018.01.12.10.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jan 2018 10:58:17 -0800 (PST)
Date: Fri, 12 Jan 2018 19:57:35 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v6 01/24] x86/mm: Define CONFIG_SPF
In-Reply-To: <1515777968-867-2-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1801121955150.2371@nanos>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com> <1515777968-867-2-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Fri, 12 Jan 2018, Laurent Dufour wrote:

> Introduce CONFIG_SPF which turns on the Speculative Page Fault handler when
> building for 64bits with SMP.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  arch/x86/Kconfig | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index a317d5594b6a..d74353b85aaf 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -2882,6 +2882,10 @@ config X86_DMA_REMAP
>  config HAVE_GENERIC_GUP
>  	def_bool y
>  
> +config SPF
> +	def_bool y
> +	depends on X86_64 && SMP

Can you please put that into a generic place as

    config SPF
    	   bool

and let the architectures select it.

Also SPF could be bit more elaborate and self explaining for the causual
reader. 3 letter acronyms are reserved for non existing agencies.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
