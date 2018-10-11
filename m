Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 763116B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 14:46:05 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id l24-v6so8741807iok.21
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:46:05 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id o21-v6si20626037jad.76.2018.10.11.11.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Oct 2018 11:46:04 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
References: <20181005161642.2462-1-logang@deltatee.com>
 <20181005161642.2462-6-logang@deltatee.com> <20181011133730.GB7276@lst.de>
 <8cea5ffa-5fbf-8ea2-b673-20e2d09a910d@deltatee.com>
Message-ID: <83cfd2d7-b840-b0c6-594e-8b39be8177c1@deltatee.com>
Date: Thu, 11 Oct 2018 12:45:56 -0600
MIME-Version: 1.0
In-Reply-To: <8cea5ffa-5fbf-8ea2-b673-20e2d09a910d@deltatee.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 5/5] RISC-V: Implement sparsemem
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Rob Herring <robh@kernel.org>, Albert Ou <aou@eecs.berkeley.edu>, Andrew Waterman <andrew@sifive.com>, linux-sh@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-kernel@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Zong Li <zong@andestech.com>, linux-mm@kvack.org, Olof Johansson <olof@lixom.net>, linux-riscv@lists.infradead.org, Michael Clark <michaeljclark@mac.com>, linux-arm-kernel@lists.infradead.org



On 2018-10-11 10:24 a.m., Logan Gunthorpe wrote:
> 
> 
> On 2018-10-11 7:37 a.m., Christoph Hellwig wrote:
>>> +/*
>>> + * Log2 of the upper bound of the size of a struct page. Used for sizing
>>> + * the vmemmap region only, does not affect actual memory footprint.
>>> + * We don't use sizeof(struct page) directly since taking its size here
>>> + * requires its definition to be available at this point in the inclusion
>>> + * chain, and it may not be a power of 2 in the first place.
>>> + */
>>> +#define STRUCT_PAGE_MAX_SHIFT	6
>>
>> I know this is copied from arm64, but wouldn't this be a good time
>> to move this next to the struct page defintion?

Ok, I spoke too soon...

Having this define next to the struct page definition works great for
riscv. However, making that happen in arm64 seems to be a nightmare. The
include chain in arm64 is tangled up so much that including mm_types
where this is needed seems to be extremely difficult.

Unless you have any ideas, this might not be possible.

Logan
