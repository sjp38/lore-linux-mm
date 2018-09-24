Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48E358E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:06:59 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l11-v6so22845925qkk.0
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:06:59 -0700 (PDT)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80128.outbound.protection.outlook.com. [40.107.8.128])
        by mx.google.com with ESMTPS id h52-v6si1530966qtc.140.2018.09.24.09.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 09:06:58 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180923224206.GA13618@ming.t460p>
 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
 <1537801706.195115.7.camel@acm.org>
 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
 <1537804720.195115.9.camel@acm.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
Date: Mon, 24 Sep 2018 19:07:18 +0300
MIME-Version: 1.0
In-Reply-To: <1537804720.195115.9.camel@acm.org>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bvanassche@acm.org>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>



On 09/24/2018 06:58 PM, Bart Van Assche wrote:
> On Mon, 2018-09-24 at 18:52 +0300, Andrey Ryabinin wrote:
>> Yes, with CONFIG_DEBUG_SLAB=y, CONFIG_SLUB_DEBUG_ON=y kmalloc() guarantees
>> that result is aligned on ARCH_KMALLOC_MINALIGN boundary.
> 
> Had you noticed that Vitaly Kuznetsov showed that this is not the case? See
> also https://lore.kernel.org/lkml/87h8ij0zot.fsf@vitty.brq.redhat.com/.
> 

I'm not following. On x86-64 ARCH_KMALLOC_MINALIGN is 8, all pointers that Vitaly Kuznetsov showed are 8-byte aligned.

> Thanks,
> 
> Bart.
> 
