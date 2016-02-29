Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2C6828E4
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:46:53 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fy10so90138830pac.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 02:46:53 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a8si12813730pas.149.2016.02.29.02.46.52
        for <linux-mm@kvack.org>;
        Mon, 29 Feb 2016 02:46:52 -0800 (PST)
Subject: Re: [PATCH 0/2] arm64, cma, gicv3-its: Use CMA for allocation of
 large device tables
References: <1456398164-16864-1-git-send-email-rrichter@caviumnetworks.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <56D42199.7040207@arm.com>
Date: Mon, 29 Feb 2016 10:46:49 +0000
MIME-Version: 1.0
In-Reply-To: <1456398164-16864-1-git-send-email-rrichter@caviumnetworks.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <rrichter@caviumnetworks.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Tirumalesh Chalamarla <tchalamarla@cavium.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>

Hi Robert,

On 25/02/16 11:02, Robert Richter wrote:
> From: Robert Richter <rrichter@cavium.com>
> 
> This series implements the use of CMA for allocation of large device
> tables for the arm64 gicv3 interrupt controller.
> 
> There are 2 patches, the first is for early activation of cma, which
> needs to be done before interrupt initialization to make it available
> to the gicv3. The second implements the use of CMA to allocate
> gicv3-its device tables.
> 
> This solves the problem where mem allocation is limited to 4MB. A
> previous patch sent to the list to address this that instead increases
> FORCE_MAX_ZONEORDER becomes obsolete.

I think you're looking at the problem the wrong way. Instead of going
through CMA directly, I'd rather go through the normal DMA API
(dma_alloc_coherent), which can itself try CMA (should it be enabled).

That will give you all the benefit of the CMA allocation, and also make
the driver more robust. I meant to do this for a while, and never found
the time. Any chance you could have a look?

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
