Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55C456B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 09:41:59 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c6-v6so4277656qta.6
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 06:41:59 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id i3-v6si445147qvg.215.2018.08.03.06.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 06:41:58 -0700 (PDT)
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
Date: Fri, 3 Aug 2018 09:41:55 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 08/03/2018 04:56 AM, Andy Shevchenko wrote:
> On Thu, Aug 2, 2018 at 10:57 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> Remove code duplication in error messages.  It is now safe to pas a NULL
>> dev to dev_err(), so the checks to avoid doing so are no longer
>> necessary.
>>
>> Example:
>>
>> Error message with dev != NULL:
>>   mpt3sas 0000:02:00.0: dma_pool_destroy chain pool, (____ptrval____) busy
>>
>> Same error message with dev == NULL before patch:
>>   dma_pool_destroy chain pool, (____ptrval____) busy
>>
>> Same error message with dev == NULL after patch:
>>   (NULL device *): dma_pool_destroy chain pool, (____ptrval____) busy
> Have you checked a history of this?
>
> I'm pretty sure this was created in an order to avoid bad looking (and
> in some cases frightening) "NULL device *" part.
>
> If it it's the case, I would rather leave it as is, and even not the
> case, I'm slightly more bent to the current state.
>
I did.A  "drivers/base/dmapool.c", later moved to "mm/dmapool.c", was
added in linux-2.6.3, for which dev_err() did not work will a NULL dev,
so the check was necessary back then.A  I agree that the (NULL device *):
bit is ugly, but these messages should be printed only after a kernel
bug, so it is not like they will be making a regular appearance in
dmesg.A  Considering that, I think that it is better to keep it simple.
