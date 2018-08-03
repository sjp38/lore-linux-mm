Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2E76B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 14:44:57 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id e4-v6so5004919qtj.5
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 11:44:57 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id d63-v6si979646qva.170.2018.08.03.11.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 11:44:57 -0700 (PDT)
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
 <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
 <20180803162212.GA4718@bombadil.infradead.org>
 <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
 <CAHp75VfZfhHS1Hgrm+3xJL=3gT9Bri16JJSFUJpDY0=Ev5X-PA@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <73004881-f6ae-e55e-0a24-5b3dfbd5af88@cybernetics.com>
Date: Fri, 3 Aug 2018 14:44:54 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75VfZfhHS1Hgrm+3xJL=3gT9Bri16JJSFUJpDY0=Ev5X-PA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 08/03/2018 02:38 PM, Andy Shevchenko wrote:
>
>> dma_alloc_coherent() does appear to support a NULL dev, so it might make
>> sense in theory.  But I can't find any in-tree callers that actually
>> pass a NULL dev to dma_pool_create().  So for one of the dreaded (NULL
>> device *) messages to show up, it would take both a new caller that
>> passes a NULL dev to dma_pool_create() and a bug to cause the message to
>> be printed.  Is that worth the special casing?
> So, then you need to rephrase the commit message explaining this
> ("NULL device is wrong to pass in the first place... bla bla bla").
>
Will do.
