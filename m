Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 259396B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:20:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u144so18790510wmu.1
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:20:51 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id r142si32208330wmg.88.2016.11.01.10.20.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 10:20:49 -0700 (PDT)
Date: Tue, 1 Nov 2016 17:18:33 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [RFC v2 2/7] arm: Use generic VDSO unmap and remap
Message-ID: <20161101171833.GS1041@n2100.armlinux.org.uk>
References: <20161101171101.24704-1-cov@codeaurora.org>
 <20161101171101.24704-2-cov@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161101171101.24704-2-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>
Cc: criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

You know, on its own, this patch is totally meaningless.  Sorry, there's
nothing more I can say about this.

On Tue, Nov 01, 2016 at 11:10:56AM -0600, Christopher Covington wrote:
> Checkpoint/Restore In Userspace (CRIU) needs to be able to unmap and remap
> the VDSO to successfully checkpoint and restore applications in the face of
> changing VDSO addresses due to Address Space Layout Randomization (ASLR,
> randmaps). Previously, this was implemented in architecture-specific code
> for PowerPC and x86. However, a generic version based on Laurent Dufour's
> PowerPC implementation is now available, so begin using it on ARM.
> 
> Signed-off-by: Christopher Covington <cov@codeaurora.org>
> ---
>  arch/arm/mm/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm/mm/Kconfig b/arch/arm/mm/Kconfig
> index c1799dd..1d3312b 100644
> --- a/arch/arm/mm/Kconfig
> +++ b/arch/arm/mm/Kconfig
> @@ -845,6 +845,7 @@ config VDSO
>  	depends on AEABI && MMU && CPU_V7
>  	default y if ARM_ARCH_TIMER
>  	select GENERIC_TIME_VSYSCALL
> +	select GENERIC_VDSO
>  	help
>  	  Place in the process address space an ELF shared object
>  	  providing fast implementations of gettimeofday and
> -- 
> Qualcomm Datacenter Technologies as an affiliate of Qualcomm Technologies, Inc.
> Qualcomm Technologies, Inc. is a member of the
> Code Aurora Forum, a Linux Foundation Collaborative Project.
> 

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
