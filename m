Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 570316B026F
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 16:05:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f64-v6so6292463qkb.20
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 13:05:38 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id a65-v6si232639qkg.6.2018.08.03.13.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 13:05:37 -0700 (PDT)
Subject: Re: [PATCH v2 6/9] dmapool: improve scalability of dma_pool_free
References: <eabf88b3-c40f-9973-efed-30af46f42c8d@cybernetics.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <fee77a48-a86b-75eb-7648-6e6e13c3e8e8@cybernetics.com>
Date: Fri, 3 Aug 2018 16:05:35 -0400
MIME-Version: 1.0
In-Reply-To: <eabf88b3-c40f-9973-efed-30af46f42c8d@cybernetics.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

For v3 of the patchset, I was also considering to add a note to the
kernel-doc comments for dma_pool_create() to use dma_alloc_coherent()
directly instead of a dma pool if the driver intends to allow userspace
to mmap() the returned pages, due to the new use of the _mapcount union
in struct page.A  Would you consider that useful information or pointless
trivia?
