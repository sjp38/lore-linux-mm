Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 335966B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 08:46:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j14so255757pfn.11
        for <linux-mm@kvack.org>; Wed, 02 May 2018 05:46:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t3-v6si9398729pgp.375.2018.05.02.05.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 05:46:22 -0700 (PDT)
Date: Wed, 2 May 2018 05:46:17 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: centralize SWIOTLB config symbol and misc other cleanups V3
Message-ID: <20180502124617.GA22001@infradead.org>
References: <20180425051539.1989-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180425051539.1989-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, sstabellini@kernel.org, linux-pci@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Any more comments?  Especially from the x86, mips and powerpc arch
maintainers?  I'd like to merge this in a few days as various other
patches depend on it.

On Wed, Apr 25, 2018 at 07:15:26AM +0200, Christoph Hellwig wrote:
> Hi all,
> 
> this seris aims for a single defintion of the Kconfig symbol.  To get
> there various cleanups, mostly about config symbols are included as well.
> 
> Changes since V2:
>  - swiotlb doesn't need the dma_length field by itself, so don't select it
>  - don't offer a user visible SWIOTLB choice
> 
> Chages since V1:
>  - fixed a incorrect Reviewed-by that should be a Signed-off-by.
> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu
---end quoted text---
