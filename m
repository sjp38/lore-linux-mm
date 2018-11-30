Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id E14B68E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 07:32:09 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id w68so2887899ith.0
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 04:32:09 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id i32si3554993jac.18.2018.12.08.04.32.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 08 Dec 2018 04:32:08 -0800 (PST)
Message-ID: <53c18168393e3134f7e4120a2528f972b1002c01.camel@kernel.crashing.org>
Subject: Re: use generic DMA mapping code in powerpc V4
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 30 Nov 2018 14:17:42 +1100
In-Reply-To: <20181127074253.GB30186@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
	 <20181127074253.GB30186@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Tue, 2018-11-27 at 08:42 +0100, Christoph Hellwig wrote:
> Any comments?  I'd like to at least get the ball moving on the easy
> bits.

So I had to cleanup some dust but it works on G5 with and without iommu
and 32-bit powermacs at least.

We're doing more tests, hopefully mpe can dig out some PASemi and
NXP/FSL HW as well. I'll try to review & ack the patches over the next
few days too.

Cheers,
Ben.

> On Wed, Nov 14, 2018 at 09:22:40AM +0100, Christoph Hellwig wrote:
> > Hi all,
> > 
> > this series switches the powerpc port to use the generic swiotlb and
> > noncoherent dma ops, and to use more generic code for the coherent
> > direct mapping, as well as removing a lot of dead code.
> > 
> > As this series is very large and depends on the dma-mapping tree I've
> > also published a git tree:
> > 
> >     git://git.infradead.org/users/hch/misc.git powerpc-dma.4
> > 
> > Gitweb:
> > 
> >     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.4
> > 
> > Changes since v3:
> >  - rebase on the powerpc fixes tree
> >  - add a new patch to actually make the baseline amigaone config
> >    configure without warnings
> >  - only use ZONE_DMA for 64-bit embedded CPUs, on pseries an IOMMU is
> >    always present
> >  - fix compile in mem.c for one configuration
> >  - drop the full npu removal for now, will be resent separately
> >  - a few git bisection fixes
> > 
> > The changes since v1 are to big to list and v2 was not posted in public.
> > 
> > _______________________________________________
> > iommu mailing list
> > iommu@lists.linux-foundation.org
> > https://lists.linuxfoundation.org/mailman/listinfo/iommu
> ---end quoted text---
