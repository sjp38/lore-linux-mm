Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB466B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 13:56:08 -0500 (EST)
Received: by pdjy10 with SMTP id y10so41587428pdj.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 10:56:08 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id do5si17562452pbc.105.2015.03.02.10.56.06
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 10:56:07 -0800 (PST)
Date: Mon, 2 Mar 2015 18:56:07 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 3/4] arm64: add support for memtest
Message-ID: <20150302185607.GG7919@arm.com>
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
 <1425308145-20769-4-git-send-email-vladimir.murzin@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425308145-20769-4-git-send-email-vladimir.murzin@arm.com>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <Vladimir.Murzin@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "arnd@arndb.de" <arnd@arndb.de>, Mark Rutland <Mark.Rutland@arm.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>

On Mon, Mar 02, 2015 at 02:55:44PM +0000, Vladimir Murzin wrote:
> Add support for memtest command line option.
> 
> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
> ---
>  arch/arm64/mm/init.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index ae85da6..597831b 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -190,6 +190,8 @@ void __init bootmem_init(void)
>  	min = PFN_UP(memblock_start_of_DRAM());
>  	max = PFN_DOWN(memblock_end_of_DRAM());
>  
> +	early_memtest(min << PAGE_SHIFT, max << PAGE_SHIFT);
> +
>  	/*
>  	 * Sparsemem tries to allocate bootmem in memory_present(), so must be
>  	 * done after the fixed reservations.

This is really neat, thanks for doing this Vladimir!

  Acked-by: Will Deacon <will.deacon@arm.com>

For the series, modulo Baruch's comments about Documentation updates.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
