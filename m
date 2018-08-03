Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9736B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 15:07:50 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id r1-v6so733384lfi.16
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 12:07:50 -0700 (PDT)
Received: from smtp.infotech.no (smtp.infotech.no. [82.134.31.41])
        by mx.google.com with ESMTP id v8-v6si2272518lfd.26.2018.08.03.12.07.48
        for <linux-mm@kvack.org>;
        Fri, 03 Aug 2018 12:07:48 -0700 (PDT)
Reply-To: dgilbert@interlog.com
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
 <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
 <20180803162212.GA4718@bombadil.infradead.org>
 <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
 <CAHp75VfZfhHS1Hgrm+3xJL=3gT9Bri16JJSFUJpDY0=Ev5X-PA@mail.gmail.com>
From: Douglas Gilbert <dgilbert@interlog.com>
Message-ID: <7dac7664-c224-efba-8a7c-ccdc7a4ecd40@interlog.com>
Date: Fri, 3 Aug 2018 15:07:44 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75VfZfhHS1Hgrm+3xJL=3gT9Bri16JJSFUJpDY0=Ev5X-PA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>, Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 2018-08-03 02:38 PM, Andy Shevchenko wrote:
> On Fri, Aug 3, 2018 at 8:03 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> On 08/03/2018 12:22 PM, Matthew Wilcox wrote:
>>> On Fri, Aug 03, 2018 at 06:59:20PM +0300, Andy Shevchenko wrote:
>>>>>>> I'm pretty sure this was created in an order to avoid bad looking (and
>>>>>>> in some cases frightening) "NULL device *" part.
>>>> JFYI: git log --no-merges --grep 'NULL device \*'
>>> I think those commits actually argue in favour of Tony's patch to remove
>>> the special casing.  Is it really useful to create dma pools with a NULL
>>> device?
> 
>> dma_alloc_coherent() does appear to support a NULL dev, so it might make
>> sense in theory.  But I can't find any in-tree callers that actually
>> pass a NULL dev to dma_pool_create().  So for one of the dreaded (NULL
>> device *) messages to show up, it would take both a new caller that
>> passes a NULL dev to dma_pool_create() and a bug to cause the message to
>> be printed.  Is that worth the special casing?
> 
> So, then you need to rephrase the commit message explaining this
> ("NULL device is wrong to pass in the first place... bla bla bla").
> 

"Pre-condition(s)", you might use that term for non-obvious requirements
for a function. The assumption then is if it/they are violated that
your function won't work. It also implies your function does not check them.
One implicit pre-condition on almost all C functions that take a pointer:
that the pointer points to accessible memory.

Doug Gilbert
