Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 560E18E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 10:19:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6-v6so374234pge.5
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 07:19:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p33-v6sor7189768pld.54.2018.09.24.07.19.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 07:19:20 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180923224206.GA13618@ming.t460p>
 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
Date: Mon, 24 Sep 2018 07:19:17 -0700
MIME-Version: 1.0
In-Reply-To: <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 9/24/18 2:46 AM, Andrey Ryabinin wrote:
> On 09/24/2018 01:42 AM, Ming Lei wrote:
>> On Fri, Sep 21, 2018 at 03:04:18PM +0200, Vitaly Kuznetsov wrote:
>>> Christoph Hellwig <hch@lst.de> writes:
>>>
>>>> On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
>>>>> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
>>>>> yes, is it a stable rule?
>>>>
>>>> This is the assumption in a lot of the kernel, so I think if somethings
>>>> breaks this we are in a lot of pain.
> 
> This assumption is not correct. And it's not correct at least from the beginning of the
> git era, which is even before SLUB allocator appeared. With CONFIG_DEBUG_SLAB=y
> the same as with CONFIG_SLUB_DEBUG_ON=y kmalloc return 'unaligned' objects.
> The guaranteed arch-and-config-independent alignment of kmalloc() result is "sizeof(void*)".
> 
> If objects has higher alignment requirement, the could be allocated via specifically created kmem_cache.

Hello Andrey,

The above confuses me. Can you explain to me why the following comment 
is present in include/linux/slab.h?

/*
  * kmalloc and friends return ARCH_KMALLOC_MINALIGN aligned
  * pointers. kmem_cache_alloc and friends return ARCH_SLAB_MINALIGN
  * aligned pointers.
  */

Thanks,

Bart.
