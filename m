Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 976B26B000D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 16:06:11 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c6-v6so2197832qta.6
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:06:11 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id a1-v6si2390480qkh.211.2018.07.26.13.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 13:06:10 -0700 (PDT)
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
Date: Thu, 26 Jul 2018 16:06:05 -0400
MIME-Version: 1.0
In-Reply-To: <20180726194209.GB12992@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 07/26/2018 03:42 PM, Matthew Wilcox wrote:
> On Thu, Jul 26, 2018 at 02:54:56PM -0400, Tony Battersby wrote:
>> dma_pool_free() scales poorly when the pool contains many pages because
>> pool_find_page() does a linear scan of all allocated pages.  Improve its
>> scalability by replacing the linear scan with a red-black tree lookup. 
>> In big O notation, this improves the algorithm from O(n^2) to O(n * log n).
> This is a lot of code to get us to O(n * log(n)) when we can use less
> code to go to O(n).  dma_pool_free() is passed the virtual address.
> We can go from virtual address to struct page with virt_to_page().
> In struct page, we have 5 words available (20/40 bytes), and it's trivial
> to use one of them to point to the struct dma_page.
>
Thanks for the tip.A  I will give that a try.
