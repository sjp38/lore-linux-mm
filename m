Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B09E6B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 08:28:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so776499305pfy.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 05:28:34 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p11si72355754pgc.326.2017.01.04.05.28.33
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 05:28:33 -0800 (PST)
Date: Wed, 4 Jan 2017 13:28:31 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20170104132831.GD18193@arm.com>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, catalin.marinas@arm.com, akpm@linux-foundation.org, hanjun.guo@linaro.org, xieyisheng1@huawei.com, rrichter@cavium.com, james.morse@arm.com

On Wed, Dec 14, 2016 at 09:11:47AM +0000, Ard Biesheuvel wrote:
> The NUMA code may get confused by the presence of NOMAP regions within
> zones, resulting in spurious BUG() checks where the node id deviates
> from the containing zone's node id.
> 
> Since the kernel has no business reasoning about node ids of pages it
> does not own in the first place, enable CONFIG_HOLES_IN_ZONE to ensure
> that such pages are disregarded.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  arch/arm64/Kconfig | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 111742126897..0472afe64d55 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -614,6 +614,10 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
>  	def_bool y
>  	depends on NUMA
>  
> +config HOLES_IN_ZONE
> +	def_bool y
> +	depends on NUMA
> +
>  source kernel/Kconfig.preempt
>  source kernel/Kconfig.hz

I'm happy to apply this, but I'll hold off until the first patch is queued
somewhere, since this doesn't help without the VM_BUG_ON being moved.

Alternatively, I can queue both if somebody from the mm camp acks the
first patch.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
