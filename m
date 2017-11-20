Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 027CF6B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:40:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v69so3015413wrb.3
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:40:10 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l197si8907219wma.74.2017.11.20.12.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 12:40:09 -0800 (PST)
Date: Mon, 20 Nov 2017 21:40:06 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 17/30] x86, kaiser: map debug IDT tables
In-Reply-To: <20171110193138.1185728D@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711202139240.2348@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193138.1185728D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, 10 Nov 2017, Dave Hansen wrote:
>  
> +static int kaiser_user_map_ptr_early(const void *start_addr, unsigned long size,
> +				 unsigned long flags)
> +{
> +	int ret = kaiser_add_user_map(start_addr, size, flags);
> +	WARN_ON(ret);
> +	return ret;

What's the point of the return value when it is ignored at the call site?

> +}
> +
>  /*
>   * Ensure that the top level of the (shadow) page tables are
>   * entirely populated.  This ensures that all processes that get
> @@ -374,6 +382,10 @@ void __init kaiser_init(void)
>  				  sizeof(gate_desc) * NR_VECTORS,
>  				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);
>  
> +	kaiser_user_map_ptr_early(&debug_idt_table,
> +				  sizeof(gate_desc) * NR_VECTORS,
> +				  __PAGE_KERNEL | _PAGE_GLOBAL);
> +

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
