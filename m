Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 966BE6B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 14:38:43 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id w15-v6so3184759uao.4
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 11:38:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w24-v6sor2255998uaa.20.2018.08.03.11.38.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 11:38:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com> <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
 <20180803162212.GA4718@bombadil.infradead.org> <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 3 Aug 2018 21:38:41 +0300
Message-ID: <CAHp75VfZfhHS1Hgrm+3xJL=3gT9Bri16JJSFUJpDY0=Ev5X-PA@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Fri, Aug 3, 2018 at 8:03 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> On 08/03/2018 12:22 PM, Matthew Wilcox wrote:
>> On Fri, Aug 03, 2018 at 06:59:20PM +0300, Andy Shevchenko wrote:
>>>>>> I'm pretty sure this was created in an order to avoid bad looking (and
>>>>>> in some cases frightening) "NULL device *" part.
>>> JFYI: git log --no-merges --grep 'NULL device \*'
>> I think those commits actually argue in favour of Tony's patch to remove
>> the special casing.  Is it really useful to create dma pools with a NULL
>> device?

> dma_alloc_coherent() does appear to support a NULL dev, so it might make
> sense in theory.  But I can't find any in-tree callers that actually
> pass a NULL dev to dma_pool_create().  So for one of the dreaded (NULL
> device *) messages to show up, it would take both a new caller that
> passes a NULL dev to dma_pool_create() and a bug to cause the message to
> be printed.  Is that worth the special casing?

So, then you need to rephrase the commit message explaining this
("NULL device is wrong to pass in the first place... bla bla bla").

-- 
With Best Regards,
Andy Shevchenko
