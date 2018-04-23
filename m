Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C02526B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 19:52:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p17-v6so20215096wre.7
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 16:52:34 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id q48-v6si9766562wrb.209.2018.04.23.16.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 16:52:30 -0700 (PDT)
Date: Tue, 24 Apr 2018 00:52:05 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 11/12] swiotlb: move the SWIOTLB config symbol to
 lib/Kconfig
Message-ID: <20180423235205.GH16141@n2100.armlinux.org.uk>
References: <20180423170419.20330-1-hch@lst.de>
 <20180423170419.20330-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423170419.20330-12-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-pci@vger.kernel.org, x86@kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Apr 23, 2018 at 07:04:18PM +0200, Christoph Hellwig wrote:
> This way we have one central definition of it, and user can select it as
> needed.  Note that we also add a second ARCH_HAS_SWIOTLB symbol to
> indicate the architecture supports swiotlb at all, so that we can still
> make the usage optional for a few architectures that want this feature
> to be user selectable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Hmm, this looks like we end up with NEED_SG_DMA_LENGTH=y on ARM by
default, which probably isn't a good idea - ARM pre-dates the dma_length
parameter in scatterlists, and I don't think all code is guaranteed to
do the right thing if this is enabled.

For example, arch/arm/mach-rpc/dma.c doesn't use the dma_length
member of struct scatterlist.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
