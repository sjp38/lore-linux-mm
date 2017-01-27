Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65FCC6B0253
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 03:26:34 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r144so50219155wme.0
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:26:34 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 185si1990498wmm.14.2017.01.27.00.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 00:26:33 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id r144so56520780wme.0
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:26:33 -0800 (PST)
Date: Fri, 27 Jan 2017 09:26:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 1/4] x86, mpx: introduce per-mm MPX table size
 tracking
Message-ID: <20170127082629.GB25162@gmail.com>
References: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
 <20170126224006.DED9C8D3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126224006.DED9C8D3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> Larger address spaces mean larger MPX bounds table sizes.  This
> tracks which size tables we are using.
> 
> "MAWA" is what the hardware documentation calls this feature:
> MPX Address-Width Adjust.  We will carry that nomenclature throughout
> this series.
> 
> The new field will be optimized and get packed into 'bd_addr' in a later
> patch.  But, leave it separate for now to make the series simpler.
> 
> ---
> 
>  b/arch/x86/include/asm/mmu.h |    1 +
>  b/arch/x86/include/asm/mpx.h |    9 +++++++++
>  2 files changed, 10 insertions(+)
> 
> diff -puN arch/x86/include/asm/mmu.h~mawa-020-mmu_context-mawa arch/x86/include/asm/mmu.h
> --- a/arch/x86/include/asm/mmu.h~mawa-020-mmu_context-mawa	2017-01-26 14:31:32.643673297 -0800
> +++ b/arch/x86/include/asm/mmu.h	2017-01-26 14:31:32.647673476 -0800
> @@ -34,6 +34,7 @@ typedef struct {
>  #ifdef CONFIG_X86_INTEL_MPX
>  	/* address of the bounds directory */
>  	void __user *bd_addr;
> +	int mpx_mawa;

-ENOCOMMENT.

Plus 'int' looks probably wrong, unless the hardware really wants signed shift 
values. (whatever 'mpx_mawa' is.)

Plus, while Intel is free to use sucky acronyms such as MAWA, could we please name 
this and related functionality sensibly: mpx_table_size or mpx_table_shift or 
such? The data structure comment can point out that Intel calls this 'MAWA'.

(Also, the changelog refers to a later change, which never happens in this 
series.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
