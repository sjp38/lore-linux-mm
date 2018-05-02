Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 910C76B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 08:22:55 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id g67-v6so10887820otb.10
        for <linux-mm@kvack.org>; Wed, 02 May 2018 05:22:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g43-v6si2147269otc.351.2018.05.02.05.22.54
        for <linux-mm@kvack.org>;
        Wed, 02 May 2018 05:22:54 -0700 (PDT)
Date: Wed, 2 May 2018 13:23:14 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20180502122314.GB30246@arm.com>
References: <1525247602-1565-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1525247602-1565-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ldufour@linux.vnet.ibm.com, catalin.marinas@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 02, 2018 at 03:53:21PM +0800, Ganesh Mahendran wrote:
> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
> enables Speculative Page Fault handler.

Are there are tests for this? I'm really nervous about enabling it...

Will

> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
> This patch is on top of Laurent's v10 spf
> ---
>  arch/arm64/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index eb2cf49..cd583a9 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -144,6 +144,7 @@ config ARM64
>  	select SPARSE_IRQ
>  	select SYSCTL_EXCEPTION_TRACE
>  	select THREAD_INFO_IN_TASK
> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT if SMP
>  	help
>  	  ARM 64-bit (AArch64) Linux support.
>  
> -- 
> 1.9.1
> 
