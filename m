Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4899F6B026D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 05:02:46 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id u26-v6so1971327uan.23
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 02:02:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f33-v6sor1696254uaa.68.2018.08.03.02.02.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 02:02:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1dbe6204-17fc-efd9-2381-48186cae2b94@cybernetics.com>
References: <1dbe6204-17fc-efd9-2381-48186cae2b94@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 3 Aug 2018 12:02:44 +0300
Message-ID: <CAHp75Vdj_jcv3j2pNf4EnzasN9zCJ1f+2aWwT2f5GKG=yFAm4Q@mail.gmail.com>
Subject: Re: [PATCH v2 4/9] dmapool: improve scalability of dma_pool_alloc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Thu, Aug 2, 2018 at 10:58 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> dma_pool_alloc() scales poorly when allocating a large number of pages
> because it does a linear scan of all previously-allocated pages before
> allocating a new one.  Improve its scalability by maintaining a separate
> list of pages that have free blocks ready to (re)allocate.  In big O
> notation, this improves the algorithm from O(n^2) to O(n).

>  struct dma_pool {              /* the pool */

> +#define POOL_FULL_IDX   0
> +#define POOL_AVAIL_IDX  1
> +#define POOL_N_LISTS    2
> +       struct list_head page_list[POOL_N_LISTS];

To be consistent with naming scheme and common practice I would rather
name the last one as

POOL_MAX_IDX 2

> +       INIT_LIST_HEAD(&retval->page_list[0]);
> +       INIT_LIST_HEAD(&retval->page_list[1]);

You introduced defines and don't use them.

-- 
With Best Regards,
Andy Shevchenko
