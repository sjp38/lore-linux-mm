Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7646B0075
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:25:42 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bz8so5926828wib.11
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:25:41 -0800 (PST)
Received: from caramon.arm.linux.org.uk (caramon.arm.linux.org.uk. [78.32.30.218])
        by mx.google.com with ESMTPS id wo9si7462664wjc.167.2013.12.10.13.25.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 13:25:41 -0800 (PST)
Date: Tue, 10 Dec 2013 21:25:23 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 1/2] mm/ARM: dma: fix conflicting types for
	'arm_dma_zone_size'
Message-ID: <20131210212523.GE4360@n2100.arm.linux.org.uk>
References: <1386703798-26521-1-git-send-email-santosh.shilimkar@ti.com> <1386703798-26521-2-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386703798-26521-2-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Grygorii Strashko <grygorii.strashko@ti.com>, Rob Herring <rob.herring@calxeda.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, Dec 10, 2013 at 02:29:57PM -0500, Santosh Shilimkar wrote:
> diff --git a/arch/arm/include/asm/dma.h b/arch/arm/include/asm/dma.h
> index 58b8c6a..1439b80 100644
> --- a/arch/arm/include/asm/dma.h
> +++ b/arch/arm/include/asm/dma.h
> @@ -8,7 +8,7 @@
>  #define MAX_DMA_ADDRESS	0xffffffffUL
>  #else
>  #define MAX_DMA_ADDRESS	({ \
> -	extern unsigned long arm_dma_zone_size; \
> +	extern phys_addr_t arm_dma_zone_size; \
>  	arm_dma_zone_size ? \
>  		(PAGE_OFFSET + arm_dma_zone_size) : 0xffffffffUL; })

This is wrong.  Take a moment to look at it more closely.  What does
"PAGE_OFFSET" tell you about what its returning?

What happens if arm_dma_zone_size is greater than 1GB when PAGE_OFFSET
is at the default setting of 3GB?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
