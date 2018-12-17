Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB2208E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:50:56 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id f24so12676197ioh.21
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:50:56 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id g196si7016913itg.103.2018.12.17.08.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 08:50:55 -0800 (PST)
References: <20181015175702.9036-1-logang@deltatee.com>
 <20181015175702.9036-7-logang@deltatee.com>
 <4b591ba933363e29392dba218ef63267@mailhost.ics.forth.gr>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <5fd0880c-5896-ffee-4d3c-4fce1649382e@deltatee.com>
Date: Mon, 17 Dec 2018 09:50:30 -0700
MIME-Version: 1.0
In-Reply-To: <4b591ba933363e29392dba218ef63267@mailhost.ics.forth.gr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2 6/6] RISC-V: Implement sparsemem
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Kossifidis <mick@ics.forth.gr>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Rob Herring <robh@kernel.org>, Albert Ou <aou@eecs.berkeley.edu>, Andrew Waterman <andrew@sifive.com>, Arnd Bergmann <arnd@arndb.de>, Palmer Dabbelt <palmer@sifive.com>, Stephen Bates <sbates@raithlin.com>, Zong Li <zong@andestech.com>, Olof Johansson <olof@lixom.net>, Andrew Morton <akpm@linux-foundation.org>, Michael Clark <michaeljclark@mac.com>, Christoph Hellwig <hch@lst.de>



On 2018-12-17 7:59 a.m., Nick Kossifidis wrote:
> Having memory blocks of a minimum size of 1GB doesn't make much sense. 
> It makes it harder to implement hotplug on top of this since we'll only 
> able to add/remove 1GB at a time. ARM used to do the same and they 
> switched to 27bits (https://patchwork.kernel.org/patch/9172845/), ARM64 
> still uses 1GB, x86 also uses 27bits and most archs also use something 
> below 30. I believe we should go for 27bits as well or even better have 
> this as a compile time option.

Thanks, that makes sense. I'll make the change for the next time we submit.

> BTW memblocks_present is on master now (got merged 3 days ago).

Great! We'll send an updated patch set after the merge window.

Logan
