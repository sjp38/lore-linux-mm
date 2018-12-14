Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8F398E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 11:42:35 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 129so1650992wmy.7
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 08:42:35 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x18si3516906wrm.46.2018.12.14.08.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 08:42:34 -0800 (PST)
Date: Fri, 14 Dec 2018 17:42:33 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 12/34] powerpc/cell: move dma direct window setup out
 of dma_configure
Message-ID: <20181214164233.GA27074@lst.de>
References: <20181114082314.8965-1-hch@lst.de> <20181114082314.8965-13-hch@lst.de> <871s6r3sno.fsf@concordia.ellerman.id.au> <20181212143604.GA5137@lst.de> <87mup8uti0.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mup8uti0.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Dec 15, 2018 at 12:29:11AM +1100, Michael Ellerman wrote:
> I think the problem is that we don't want to set iommu_bypass_supported
> unless cell_iommu_fixed_mapping_init() succeeds.
> 
> Yep. This makes it work for me on cell on top of your v5.

Thanks, this looks good.  I've folded it with the slight change of moving
the iommu_bypass_supported setup into cell_iommu_fixed_mapping_init.
