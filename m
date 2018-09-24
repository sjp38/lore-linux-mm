Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC8278E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:47:54 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d194-v6so22457437qkb.12
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:47:54 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id c29-v6si161542qvh.13.2018.09.24.09.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 09:47:53 -0700 (PDT)
Date: Mon, 24 Sep 2018 16:47:53 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
In-Reply-To: <1537805984.195115.14.camel@acm.org>
Message-ID: <010001660c7ae798-2c446e83-392a-40bd-a89d-8da2f20dd1b8-000000@email.amazonses.com>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com> <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com> <20180923224206.GA13618@ming.t460p> <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org> <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com> <1537801706.195115.7.camel@acm.org> <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com> <1537804720.195115.9.camel@acm.org> <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
 <1537805984.195115.14.camel@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bvanassche@acm.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, 24 Sep 2018, Bart Van Assche wrote:

> That means that two buffers allocated with kmalloc() may share a cache line on
> x86-64. Since it is allowed to use a buffer allocated by kmalloc() for DMA, can
> this lead to data corruption, e.g. if the CPU writes into one buffer allocated
> with kmalloc() and a device performs a DMA write to another kmalloc() buffer and
> both write operations affect the same cache line?

The devices writes to the cacheline through the processor which serializes
access appropriately.

The DMA device cannot write directly to memory after all on current Intel
processors. Other architectures have bus protocols that prevent situations
like that.
