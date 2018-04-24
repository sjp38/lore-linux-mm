Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14F6F6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 03:55:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l6-v6so15231145wrn.17
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 00:55:19 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 48-v6si11552164wru.268.2018.04.24.00.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 00:55:17 -0700 (PDT)
Date: Tue, 24 Apr 2018 09:56:45 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 11/12] swiotlb: move the SWIOTLB config symbol to
	lib/Kconfig
Message-ID: <20180424075645.GA19379@lst.de>
References: <20180423170419.20330-1-hch@lst.de> <20180423170419.20330-12-hch@lst.de> <20180423235205.GH16141@n2100.armlinux.org.uk> <20180424065549.GA18468@lst.de> <20180424074726.GI16141@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424074726.GI16141@n2100.armlinux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, linux-pci@vger.kernel.org, x86@kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Apr 24, 2018 at 08:47:27AM +0100, Russell King - ARM Linux wrote:
> Therefore, the default state for SWIOTLB and hence NEED_SG_DMA_LENGTH
> becomes 'y' on ARM, and any defconfig file that does not mention SWIOTLB
> explicitly ends up with both these enabled.

Indeed, sorry.

> It does look a bit weird though - patch 10 arranged stuff so that we
> didn't end up with SWIOTLB always enabled, but this patch reintroduces
> that with the allowance that the user can disable if so desired.

I am not very happy with that patch, but I have a hard time coming
up with something saner.

Bascially x86_64 and mips/loongson default to SWIOTLB=y but allow to
deselect it, powerpc has it optional without any real dependency
and defaults to n and everyone just selects it otherwise.

I suspect the right thing is to just have it always one for x86_64
and loongson and have a ppc-specific option to enable it on powerpc
so that we can always use select statements.  I'll do that for the
next round.
