Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32E486B0006
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 12:24:45 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z15-v6so8541185iob.3
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:24:45 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id f11-v6si18174255iob.49.2018.10.11.09.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Oct 2018 09:24:43 -0700 (PDT)
References: <20181005161642.2462-1-logang@deltatee.com>
 <20181005161642.2462-6-logang@deltatee.com> <20181011133730.GB7276@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <8cea5ffa-5fbf-8ea2-b673-20e2d09a910d@deltatee.com>
Date: Thu, 11 Oct 2018 10:24:33 -0600
MIME-Version: 1.0
In-Reply-To: <20181011133730.GB7276@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 5/5] RISC-V: Implement sparsemem
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Rob Herring <robh@kernel.org>, Albert Ou <aou@eecs.berkeley.edu>, Andrew Waterman <andrew@sifive.com>, linux-sh@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-kernel@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Zong Li <zong@andestech.com>, linux-mm@kvack.org, Olof Johansson <olof@lixom.net>, linux-riscv@lists.infradead.org, Michael Clark <michaeljclark@mac.com>, linux-arm-kernel@lists.infradead.org



On 2018-10-11 7:37 a.m., Christoph Hellwig wrote:
>> +/*
>> + * Log2 of the upper bound of the size of a struct page. Used for sizing
>> + * the vmemmap region only, does not affect actual memory footprint.
>> + * We don't use sizeof(struct page) directly since taking its size here
>> + * requires its definition to be available at this point in the inclusion
>> + * chain, and it may not be a power of 2 in the first place.
>> + */
>> +#define STRUCT_PAGE_MAX_SHIFT	6
> 
> I know this is copied from arm64, but wouldn't this be a good time
> to move this next to the struct page defintion?
> 
> Also this:
> 
> arch/arm64/mm/init.c:   BUILD_BUG_ON(sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT));
> 
> should move to comment code (or would have to be duplicated for riscv)

Makes sense. Where is a good place for the BUILD_BUG_ON in common code?

I've queued up changes for your other feedback.

Thanks,

Logan
