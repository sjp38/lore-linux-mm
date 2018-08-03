Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30EE06B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 17:02:24 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so3105326pgp.4
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 14:02:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q16-v6si4422141pls.404.2018.08.03.14.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 Aug 2018 14:02:21 -0700 (PDT)
Date: Fri, 3 Aug 2018 14:02:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 6/9] dmapool: improve scalability of dma_pool_free
Message-ID: <20180803210215.GA9329@bombadil.infradead.org>
References: <eabf88b3-c40f-9973-efed-30af46f42c8d@cybernetics.com>
 <fee77a48-a86b-75eb-7648-6e6e13c3e8e8@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fee77a48-a86b-75eb-7648-6e6e13c3e8e8@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

On Fri, Aug 03, 2018 at 04:05:35PM -0400, Tony Battersby wrote:
> For v3 of the patchset, I was also considering to add a note to the
> kernel-doc comments for dma_pool_create() to use dma_alloc_coherent()
> directly instead of a dma pool if the driver intends to allow userspace
> to mmap() the returned pages, due to the new use of the _mapcount union
> in struct page.  Would you consider that useful information or pointless
> trivia?

If userspace is going to map the pages, it's going to expose other things
to userspace than the dma pages.  I'd suggest they not do this; they
should do their own sub-allocation which only exposes to an individual
task the data they're sure is OK for each task to see.
