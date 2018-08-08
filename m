Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2B96B000C
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 05:51:59 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id z12-v6so1299531uao.0
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 02:51:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x30-v6sor1413417uah.108.2018.08.08.02.51.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 02:51:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5d0aec14-73e0-280d-62fb-2b0fe6c01418@cybernetics.com>
References: <5d0aec14-73e0-280d-62fb-2b0fe6c01418@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Wed, 8 Aug 2018 12:51:57 +0300
Message-ID: <CAHp75VfQJPrBPG8_LLQ0Nvs9S8eaQzpwXhf67kA5Cknwy37aTA@mail.gmail.com>
Subject: Re: [PATCH v3 07/10] dmapool: cleanup integer types
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

On Tue, Aug 7, 2018 at 7:48 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> To represent the size of a single allocation, dmapool currently uses
> 'unsigned int' in some places and 'size_t' in other places.  Standardize
> on 'unsigned int' to reduce overhead, but use 'size_t' when counting all
> the blocks in the entire pool.

>         else if ((boundary < size) || (boundary & (boundary - 1)))
>                 return NULL;

Just a side note: in above it's is_power_of_2() opencoded.

-- 
With Best Regards,
Andy Shevchenko
