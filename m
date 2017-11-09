Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23B1D440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 20:30:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p9so4464027pgc.6
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 17:30:38 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id k6si4832192pgq.102.2017.11.08.17.30.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 17:30:37 -0800 (PST)
Subject: Re: [PATCH for-next 2/4] RDMA/hns: Add IOMMU enable support in hip08
References: <1506763741-81429-1-git-send-email-xavier.huwei@huawei.com>
 <1506763741-81429-3-git-send-email-xavier.huwei@huawei.com>
 <20170930161023.GI2965@mtr-leonro.local> <59DF60A3.7080803@huawei.com>
 <5fe5f9b9-2c2b-ab3c-dafa-3e2add051bbb@arm.com> <59F97BBE.5070207@huawei.com>
 <fc7433af-4fa7-6b78-6bec-26941a427002@arm.com> <5A011E49.6060407@huawei.com>
 <20171107154838.GC21466@ziepe.ca>
From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Message-ID: <5A03AFA0.5090505@huawei.com>
Date: Thu, 9 Nov 2017 09:30:08 +0800
MIME-Version: 1.0
In-Reply-To: <20171107154838.GC21466@ziepe.ca>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Robin Murphy <robin.murphy@arm.com>, Leon Romanovsky <leon@kernel.org>, shaobo.xu@intel.com, xavier.huwei@tom.com, lijun_nudt@163.com, oulijun@huawei.com, linux-rdma@vger.kernel.org, charles.chenxin@huawei.com, linuxarm@huawei.com, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dledford@redhat.com, liuyixian@huawei.com, zhangxiping3@huawei.com, shaoboxu@tom.com



On 2017/11/7 23:48, Jason Gunthorpe wrote:
> On Tue, Nov 07, 2017 at 10:45:29AM +0800, Wei Hu (Xavier) wrote:
>
>>     We reconstruct the code as below:
>>             It replaces dma_alloc_coherent with __get_free_pages and
>> dma_map_single functions. So, we can vmap serveral ptrs returned by
>> __get_free_pages, right?
> Can't you just use vmalloc and dma_map that? Other drivers follow that
> approach..
>
> However, dma_alloc_coherent and dma_map_single are not the same
> thing. You can't touch the vmap memory once you call dma_map unless
> the driver also includes dma cache flushing calls in all the right
> places.
>
> The difference is that alloc_coherent will return non-cachable memory
> if necessary, while get_free_pages does not.
>
> Jason

Hi, Jason
    Thanks for your suggestion.
    We will fix it.
	
    Regards
Wei Hu

>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
