Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54BE16B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 23:54:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y6-v6so11438701wrm.10
        for <linux-mm@kvack.org>; Wed, 02 May 2018 20:54:07 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y81-v6si11517729wrc.314.2018.05.02.20.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 20:54:03 -0700 (PDT)
Date: Thu, 3 May 2018 05:56:43 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 11/13] mips,unicore32: swiotlb doesn't need
	sg->dma_length
Message-ID: <20180503035643.GA9781@lst.de>
References: <20180425051539.1989-1-hch@lst.de> <20180425051539.1989-12-hch@lst.de> <20180502222017.GC20766@jamesdev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502222017.GC20766@jamesdev>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <jhogan@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Wed, May 02, 2018 at 11:20:18PM +0100, James Hogan wrote:
> On Wed, Apr 25, 2018 at 07:15:37AM +0200, Christoph Hellwig wrote:
> > Only mips and unicore32 select CONFIG_NEED_SG_DMA_LENGTH when building
> > swiotlb.  swiotlb itself never merges segements and doesn't accesses the
> > dma_length field directly, so drop the dependency.
> 
> Is that at odds with Documentation/DMA-API-HOWTO.txt, which seems to
> suggest arch ports should enable it for IOMMUs?

swiotlb isn't really an iommu..  That being said iommus don't have to
merge segments either if they don't want to, and we have various
implementations that don't.  The whole dma api documentation needs
a major overhaul, including merging the various files and dropping a lot
of dead wood.  It has been on my todo list for a while, with an inner
hope that someone else would do it before me.
