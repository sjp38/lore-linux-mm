Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7EB6B24A5
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:44:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m25-v6so1052543pgv.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 06:44:57 -0700 (PDT)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id f65-v6si1742055pgc.20.2018.08.22.06.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 06:44:55 -0700 (PDT)
Subject: Re: [PATCH 0/4] numa, iommu/smmu: IOMMU/SMMU driver optimization for
 NUMA systems
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
From: John Garry <john.garry@huawei.com>
Message-ID: <452f1665-eb3a-5e8c-f671-099ef4a15d84@huawei.com>
Date: Wed, 22 Aug 2018 14:44:33 +0100
MIME-Version: 1.0
In-Reply-To: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Will.Deacon@arm.com" <Will.Deacon@arm.com>, "gklkml16@gmail.com" <gklkml16@gmail.com>, "Tomasz.Nowicki@cavium.com" <Tomasz.Nowicki@cavium.com>, "Robert.Richter@cavium.com" <Robert.Richter@cavium.com>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "jnair@caviumnetworks.com" <jnair@caviumnetworks.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, Linuxarm <linuxarm@huawei.com>, Christoph
 Hellwig <hch@lst.de>

On 21/09/2017 09:59, Ganapatrao Kulkarni wrote:
> Adding numa aware memory allocations used for iommu dma allocation and
> memory allocated for SMMU stream tables, page walk tables and command queues.
>
> With this patch, iperf testing on ThunderX2, with 40G NIC card on
> NODE 1 PCI shown same performance(around 30% improvement) as NODE 0.
>
> Ganapatrao Kulkarni (4):
>   mm: move function alloc_pages_exact_nid out of __meminit
>   numa, iommu/io-pgtable-arm: Use NUMA aware memory allocation for smmu
>     translation tables
>   iommu/arm-smmu-v3: Use NUMA memory allocations for stream tables and
>     comamnd queues
>   iommu/dma, numa: Use NUMA aware memory allocations in
>     __iommu_dma_alloc_pages
>
>  drivers/iommu/arm-smmu-v3.c    | 57 +++++++++++++++++++++++++++++++++++++-----
>  drivers/iommu/dma-iommu.c      | 17 +++++++------
>  drivers/iommu/io-pgtable-arm.c |  4 ++-
>  include/linux/gfp.h            |  2 +-
>  mm/page_alloc.c                |  3 ++-
>  5 files changed, 67 insertions(+), 16 deletions(-)
>

Hi Ganapatrao,

Have you any plans for further work on this patchset? I have not seen 
anything since this v1 was posted+discussed.

Thanks,
John

> --
> 2.9.4
>
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
>
> .
>
