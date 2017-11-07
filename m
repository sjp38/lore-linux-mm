Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42641280269
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 10:58:24 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id w24so17223452pgm.7
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 07:58:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q30si1590855pgc.273.2017.11.07.07.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 07:58:23 -0800 (PST)
Date: Tue, 7 Nov 2017 07:58:05 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH for-next 2/4] RDMA/hns: Add IOMMU enable support in hip08
Message-ID: <20171107155805.GA24082@infradead.org>
References: <1506763741-81429-1-git-send-email-xavier.huwei@huawei.com>
 <1506763741-81429-3-git-send-email-xavier.huwei@huawei.com>
 <20170930161023.GI2965@mtr-leonro.local>
 <59DF60A3.7080803@huawei.com>
 <5fe5f9b9-2c2b-ab3c-dafa-3e2add051bbb@arm.com>
 <59F97BBE.5070207@huawei.com>
 <fc7433af-4fa7-6b78-6bec-26941a427002@arm.com>
 <5A011E49.6060407@huawei.com>
 <20171107154838.GC21466@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107154838.GC21466@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Leon Romanovsky <leon@kernel.org>, shaobo.xu@intel.com, xavier.huwei@tom.com, lijun_nudt@163.com, oulijun@huawei.com, linux-rdma@vger.kernel.org, charles.chenxin@huawei.com, linuxarm@huawei.com, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dledford@redhat.com, liuyixian@huawei.com, zhangxiping3@huawei.com, shaoboxu@tom.com

On Tue, Nov 07, 2017 at 08:48:38AM -0700, Jason Gunthorpe wrote:
> Can't you just use vmalloc and dma_map that? Other drivers follow that
> approach..

You can't easily due to the flushing requirements.  We used to do that
in XFS and it led to problems.  You need the page allocator + vmap +
invalidate_kernel_vmap_range + flush_kernel_vmap_range to get the
cache flushing right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
