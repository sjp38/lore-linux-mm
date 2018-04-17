Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C070E6B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 02:10:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id m7so15120230wrb.16
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 23:10:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h58si900686edh.321.2018.04.16.23.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 23:10:48 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H69ucE034972
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 02:10:47 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hdbbng5yb-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 02:10:46 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 07:10:44 +0100
Subject: Re: [PATCH 11/12] swiotlb: move the SWIOTLB config symbol to
 lib/Kconfig
References: <20180415145947.1248-1-hch@lst.de>
 <20180415145947.1248-12-hch@lst.de>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2018 11:40:36 +0530
MIME-Version: 1.0
In-Reply-To: <20180415145947.1248-12-hch@lst.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1c4007b5-c0d4-7077-b2c1-767c6abbf79f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 04/15/2018 08:29 PM, Christoph Hellwig wrote:
> This way we have one central definition of it, and user can select it as
> needed.  Note that we also add a second ARCH_HAS_SWIOTLB symbol to
> indicate the architecture supports swiotlb at all, so that we can still
> make the usage optional for a few architectures that want this feature
> to be user selectable.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>


snip

> +
> +config SWIOTLB
> +	bool "SWIOTLB support"
> +	default ARCH_HAS_SWIOTLB
> +	select DMA_DIRECT_OPS
> +	select NEED_DMA_MAP_STATE
> +	select NEED_SG_DMA_LENGTH
> +	---help---
> +	  Support for IO bounce buffering for systems without an IOMMU.
> +	  This allows us to DMA to the full physical address space on
> +	  platforms where the size of a physical address is larger
> +	  than the bus address.  If unsure, say Y.
> +
>  config CHECK_SIGNATURE
>  	bool

Pulling DMA_DIRECT_OPS config option by default when SWIOTLB is enabled
makes sense. This option was also needed to be enabled separately even
to use swiotlb_dma_ops.
