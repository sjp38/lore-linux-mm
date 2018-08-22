Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B23686B253D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 12:08:35 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id r14-v6so1158530pls.23
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 09:08:35 -0700 (PDT)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id i126-v6si1681430pgd.332.2018.08.22.09.08.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 09:08:34 -0700 (PDT)
Subject: Re: [PATCH 0/4] numa, iommu/smmu: IOMMU/SMMU driver optimization for
 NUMA systems
References: <20170921085922.11659-1-ganapatrao.kulkarni@cavium.com>
 <452f1665-eb3a-5e8c-f671-099ef4a15d84@huawei.com>
 <a7fc1e43-3652-562a-1e59-499be80b567c@arm.com>
From: John Garry <john.garry@huawei.com>
Message-ID: <ec57224a-7673-97d8-bb0c-c612080625bc@huawei.com>
Date: Wed, 22 Aug 2018 17:07:55 +0100
MIME-Version: 1.0
In-Reply-To: <a7fc1e43-3652-562a-1e59-499be80b567c@arm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>, Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Will.Deacon@arm.com" <Will.Deacon@arm.com>, "gklkml16@gmail.com" <gklkml16@gmail.com>, "Tomasz.Nowicki@cavium.com" <Tomasz.Nowicki@cavium.com>, "Robert.Richter@cavium.com" <Robert.Richter@cavium.com>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "jnair@caviumnetworks.com" <jnair@caviumnetworks.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, Linuxarm <linuxarm@huawei.com>, Christoph
 Hellwig <hch@lst.de>

On 22/08/2018 15:56, Robin Murphy wrote:
> Hi John,
>
> On 22/08/18 14:44, John Garry wrote:
>> On 21/09/2017 09:59, Ganapatrao Kulkarni wrote:
>>> Adding numa aware memory allocations used for iommu dma allocation and
>>> memory allocated for SMMU stream tables, page walk tables and command
>>> queues.
>>>
>>> With this patch, iperf testing on ThunderX2, with 40G NIC card on
>>> NODE 1 PCI shown same performance(around 30% improvement) as NODE 0.
>>>
>>> Ganapatrao Kulkarni (4):
>>>   mm: move function alloc_pages_exact_nid out of __meminit
>>>   numa, iommu/io-pgtable-arm: Use NUMA aware memory allocation for smmu
>>>     translation tables
>>>   iommu/arm-smmu-v3: Use NUMA memory allocations for stream tables and
>>>     comamnd queues
>>>   iommu/dma, numa: Use NUMA aware memory allocations in
>>>     __iommu_dma_alloc_pages
>>>
>>>  drivers/iommu/arm-smmu-v3.c    | 57
>>> +++++++++++++++++++++++++++++++++++++-----
>>>  drivers/iommu/dma-iommu.c      | 17 +++++++------
>>>  drivers/iommu/io-pgtable-arm.c |  4 ++-
>>>  include/linux/gfp.h            |  2 +-
>>>  mm/page_alloc.c                |  3 ++-
>>>  5 files changed, 67 insertions(+), 16 deletions(-)
>>>
>>
>> Hi Ganapatrao,
>>
>> Have you any plans for further work on this patchset? I have not seen
>> anything since this v1 was posted+discussed.
>

Hi Robin,

Thanks for the info. I thought I remembered 4b12 but couldn't put my 
finger on it.

> Looks like I ended up doing the version of the io-pgtable change that I
> suggested here, which was merged recently (4b123757eeaa). Patch #3
> should also be effectively obsolete now since the SWIOTLB/dma-direct
> rework (21f237e4d085). Apparently I also started reworking patch #4 in
> my tree at some point but sidelined it - I think that was at least
> partly due to another thread[1] which made it seem less clear-cut
> whether this is always the right thing to do.

Right, so #4 seems less straightforward and not directly related to 
IOMMU driver anyway.

Cheers,
John

>
> Robin.
>
> [1]
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1693026.html
>
> .
>
