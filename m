Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFF86B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 04:56:03 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id t22-v6so1978039uap.19
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 01:56:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s28-v6sor1515931uab.252.2018.08.03.01.56.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 01:56:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 3 Aug 2018 11:56:01 +0300
Message-ID: <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Thu, Aug 2, 2018 at 10:57 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> Remove code duplication in error messages.  It is now safe to pas a NULL
> dev to dev_err(), so the checks to avoid doing so are no longer
> necessary.
>
> Example:
>
> Error message with dev != NULL:
>   mpt3sas 0000:02:00.0: dma_pool_destroy chain pool, (____ptrval____) busy
>
> Same error message with dev == NULL before patch:
>   dma_pool_destroy chain pool, (____ptrval____) busy
>
> Same error message with dev == NULL after patch:
>   (NULL device *): dma_pool_destroy chain pool, (____ptrval____) busy

Have you checked a history of this?

I'm pretty sure this was created in an order to avoid bad looking (and
in some cases frightening) "NULL device *" part.

If it it's the case, I would rather leave it as is, and even not the
case, I'm slightly more bent to the current state.

-- 
With Best Regards,
Andy Shevchenko
