Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC34F6B0273
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 16:09:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x19-v6so2107755pfh.15
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 13:09:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 94-v6si2335925plb.59.2018.08.02.13.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Aug 2018 13:09:00 -0700 (PDT)
Date: Thu, 2 Aug 2018 13:08:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 5/9] dmapool: rename fields in dma_page
Message-ID: <20180802200857.GB14318@bombadil.infradead.org>
References: <e2badcf3-c284-5c2d-6fa9-4efa4fd9f19a@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2badcf3-c284-5c2d-6fa9-4efa4fd9f19a@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

On Thu, Aug 02, 2018 at 03:59:15PM -0400, Tony Battersby wrote:
> Rename fields in 'struct dma_page' in preparation for moving them into
> 'struct page'.  No functional changes.
> 
> in_use -> dma_in_use
> offset -> dma_free_o

I don't like dma_free_o.  dma_free_off is OK by me.
