Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB100440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 20:27:19 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id p138so6996093itp.9
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 17:27:19 -0800 (PST)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTP id l101si4582769ioi.243.2017.11.08.17.27.18
        for <linux-mm@kvack.org>;
        Wed, 08 Nov 2017 17:27:19 -0800 (PST)
Subject: Re: [PATCH for-next 2/4] RDMA/hns: Add IOMMU enable support in hip08
References: <1506763741-81429-1-git-send-email-xavier.huwei@huawei.com>
 <1506763741-81429-3-git-send-email-xavier.huwei@huawei.com>
 <20170930161023.GI2965@mtr-leonro.local> <59DF60A3.7080803@huawei.com>
 <5fe5f9b9-2c2b-ab3c-dafa-3e2add051bbb@arm.com> <59F97BBE.5070207@huawei.com>
 <fc7433af-4fa7-6b78-6bec-26941a427002@arm.com> <5A011E49.6060407@huawei.com>
 <20171107154838.GC21466@ziepe.ca> <20171107155805.GA24082@infradead.org>
From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Message-ID: <5A03AEC3.10109@huawei.com>
Date: Thu, 9 Nov 2017 09:26:27 +0800
MIME-Version: 1.0
In-Reply-To: <20171107155805.GA24082@infradead.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: Robin Murphy <robin.murphy@arm.com>, Leon Romanovsky <leon@kernel.org>, shaobo.xu@intel.com, xavier.huwei@tom.com, lijun_nudt@163.com, oulijun@huawei.com, linux-rdma@vger.kernel.org, charles.chenxin@huawei.com, linuxarm@huawei.com, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dledford@redhat.com, liuyixian@huawei.com, zhangxiping3@huawei.com, shaoboxu@tom.com



On 2017/11/7 23:58, Christoph Hellwig wrote:
> On Tue, Nov 07, 2017 at 08:48:38AM -0700, Jason Gunthorpe wrote:
>> Can't you just use vmalloc and dma_map that? Other drivers follow that
>> approach..
> You can't easily due to the flushing requirements.  We used to do that
> in XFS and it led to problems.  You need the page allocator + vmap +
> invalidate_kernel_vmap_range + flush_kernel_vmap_range to get the
> cache flushing right.
>
> .
Hi, Christoph Hellwig
    Thanks for your suggestion.
    Regards
Wei Hu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
