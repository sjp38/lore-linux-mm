Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F22F6B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:27:56 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b189so4598217oia.10
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:27:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d34si3786880otc.100.2017.10.18.06.27.55
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 06:27:55 -0700 (PDT)
Date: Wed, 18 Oct 2017 14:28:00 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 0/4] numa, iommu/smmu: IOMMU/SMMU driver optimization for
 NUMA systems
Message-ID: <20171018132759.GA21820@arm.com>
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, robin.murphy@arm.com, lorenzo.pieralisi@arm.com, hanjun.guo@linaro.org, joro@8bytes.org, vbabka@suse.cz, akpm@linux-foundation.org, mhocko@suse.com, Tomasz.Nowicki@cavium.com, Robert.Richter@cavium.com, jnair@caviumnetworks.com, gklkml16@gmail.com

Hi Ganapat,

On Thu, Sep 21, 2017 at 02:29:18PM +0530, Ganapatrao Kulkarni wrote:
> Adding numa aware memory allocations used for iommu dma allocation and
> memory allocated for SMMU stream tables, page walk tables and command queues.
> 
> With this patch, iperf testing on ThunderX2, with 40G NIC card on
> NODE 1 PCI shown same performance(around 30% improvement) as NODE 0.

Are you planning to repost this series? The idea looks good, but it needs
some rework before it can be merged.

Thanks,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
