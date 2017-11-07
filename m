Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71AB7280269
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 10:48:41 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id n33so2569932ioi.7
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 07:48:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h10sor1005944ith.30.2017.11.07.07.48.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 07:48:40 -0800 (PST)
Date: Tue, 7 Nov 2017 08:48:38 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH for-next 2/4] RDMA/hns: Add IOMMU enable support in hip08
Message-ID: <20171107154838.GC21466@ziepe.ca>
References: <1506763741-81429-1-git-send-email-xavier.huwei@huawei.com>
 <1506763741-81429-3-git-send-email-xavier.huwei@huawei.com>
 <20170930161023.GI2965@mtr-leonro.local>
 <59DF60A3.7080803@huawei.com>
 <5fe5f9b9-2c2b-ab3c-dafa-3e2add051bbb@arm.com>
 <59F97BBE.5070207@huawei.com>
 <fc7433af-4fa7-6b78-6bec-26941a427002@arm.com>
 <5A011E49.6060407@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A011E49.6060407@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Leon Romanovsky <leon@kernel.org>, shaobo.xu@intel.com, xavier.huwei@tom.com, lijun_nudt@163.com, oulijun@huawei.com, linux-rdma@vger.kernel.org, charles.chenxin@huawei.com, linuxarm@huawei.com, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dledford@redhat.com, liuyixian@huawei.com, zhangxiping3@huawei.com, shaoboxu@tom.com

On Tue, Nov 07, 2017 at 10:45:29AM +0800, Wei Hu (Xavier) wrote:

>     We reconstruct the code as below:

>             It replaces dma_alloc_coherent with __get_free_pages and
> dma_map_single functions. So, we can vmap serveral ptrs returned by
> __get_free_pages, right?

Can't you just use vmalloc and dma_map that? Other drivers follow that
approach..

However, dma_alloc_coherent and dma_map_single are not the same
thing. You can't touch the vmap memory once you call dma_map unless
the driver also includes dma cache flushing calls in all the right
places.

The difference is that alloc_coherent will return non-cachable memory
if necessary, while get_free_pages does not.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
