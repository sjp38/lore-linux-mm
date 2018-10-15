Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 930F46B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:39:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q143-v6so14915564pgq.12
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 10:39:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8-v6sor2258815plt.62.2018.10.15.10.39.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 10:39:31 -0700 (PDT)
Date: Mon, 15 Oct 2018 10:39:29 -0700 (PDT)
Subject: Re: [PATCH 5/5] RISC-V: Implement sparsemem
In-Reply-To: <15C8B877-4BBE-47E1-98D1-945E9355E757@raithlin.com>
From: Palmer Dabbelt <palmer@sifive.com>
Message-ID: <mhng-d8f1905a-8985-4797-b05b-b165b4ce91f1@palmer-si-x1c4>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sbates@raithlin.com
Cc: logang@deltatee.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, aou@eecs.berkeley.edu, Christoph Hellwig <hch@lst.de>logang@deltatee.com, Andrew Waterman <andrew@sifive.com>, Olof Johansson <olof@lixom.net>, Michael Clark <michaeljclark@mac.com>, robh@kernel.org, zong@andestech.com

On Thu, 11 Oct 2018 05:18:20 PDT (-0700), sbates@raithlin.com wrote:
> Palmer
> 
>> I don't really know anything about this, but you're welcome to add a
>>    
>>    Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
> 
> Thanks. I think it would be good to get someone who's familiar with linux/mm to take a look.
>     
>> if you think it'll help.  I'm assuming you're targeting a different tree for 
>> the patch set, in which case it's probably best to keep this together with the 
>> rest of it.
> 
> No I think this series should be pulled by the RISC-V maintainer. The other patches in this series just refactor some code and need to be ACK'ed by their ARCH developers but I suspect the series should be pulled into RISC-V. That said since it does touch other arch should it be pulled by mm? 
> 
> BTW note that RISC-V SPARSEMEM support is pretty useful for all manner of things and not just the p2pdma discussed in the cover.

Ah, OK -- I thought this was adding the support everywhere.  Do you mind 
re-sending the patches with the various acks/reviews and I'll put in on 
for-next?

>     
>> Thanks for porting your stuff to RISC-V!
> 
> You bet ;-)
