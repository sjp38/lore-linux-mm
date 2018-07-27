Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE6C86B0269
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:35:57 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id d134-v6so2488239vkf.5
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:35:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184-v6sor2076784vkt.1.2018.07.27.14.35.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 14:35:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <88d362b7-1d53-b430-1741-b48cbc0a7887@cybernetics.com>
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org> <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
 <20180727000708.GA785@bombadil.infradead.org> <cae33099-3147-5014-ab4e-c22a4d66dc49@cybernetics.com>
 <20180727152322.GB13348@bombadil.infradead.org> <acdc2e32-466c-61d3-145f-80bfba2c6739@cybernetics.com>
 <88d362b7-1d53-b430-1741-b48cbc0a7887@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Sat, 28 Jul 2018 00:35:55 +0300
Message-ID: <CAHp75VcjMg2RABg4F3u=wpgQvGK8qr-4wxeRNmJtfMAE2VRRAw@mail.gmail.com>
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Sat, Jul 28, 2018 at 12:27 AM, Tony Battersby <tonyb@cybernetics.com> wrote:
> On 07/27/2018 03:38 PM, Tony Battersby wrote:
>> But the bigger problem is that my first patch adds another list_head to
>> the dma_page for the avail_page_link to make allocations faster.  I
>> suppose we could make the lists singly-linked instead of doubly-linked
>> to save space.
>>
>
> I managed to redo my dma_pool_alloc() patch to make avail_page_list
> singly-linked instead of doubly-linked.

Are you relying on llist.h implementation?

Btw, did you see quicklist.h?


-- 
With Best Regards,
Andy Shevchenko
