Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5028E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 20:21:13 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p192-v6so23325685qke.13
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 17:21:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d10-v6si599801qvh.83.2018.09.24.17.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 17:21:12 -0700 (PDT)
Date: Tue, 25 Sep 2018 08:20:58 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180925002057.GB14386@ming.t460p>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de>
 <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180923224206.GA13618@ming.t460p>
 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
 <010001660c27f079-7ba54431-6f0c-430a-8db5-2398a8e761f0-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001660c27f079-7ba54431-6f0c-430a-8db5-2398a8e761f0-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Bart Van Assche <bvanassche@acm.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Sep 24, 2018 at 03:17:16PM +0000, Christopher Lameter wrote:
> On Mon, 24 Sep 2018, Bart Van Assche wrote:
> 
> > /*
> >  * kmalloc and friends return ARCH_KMALLOC_MINALIGN aligned
> >  * pointers. kmem_cache_alloc and friends return ARCH_SLAB_MINALIGN
> >  * aligned pointers.
> >  */
> 
> kmalloc alignment is only guaranteed to ARCH_KMALLOC_MINALIGN. That power
> of 2 byte caches (without certain options) are aligned to the power of 2
> is due to the nature that these objects are stored in SLUB. Other
> allocators may behave different and actually different debug options
> result in different alignments. You cannot rely on that.
> 
> ARCH_KMALLOC minalign shows the mininum alignment guarantees. If that is
> not sufficient and you do not want to change the arch guarantees then you
> can open you own slab cache with kmem_cache_create() where you can specify
> different alignment requirements.

Christopher, thank you for clarifying the point!

Then looks it should be reasonable for XFS to switch to kmem_cache_create()
for addressing this issue.

Thanks,
Ming
