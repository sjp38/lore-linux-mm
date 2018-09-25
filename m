Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC2BE8E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 00:44:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a4-v6so2756454pfi.16
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 21:44:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t2-v6si1329647pgg.422.2018.09.24.21.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Sep 2018 21:44:26 -0700 (PDT)
Date: Mon, 24 Sep 2018 21:44:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180925044421.GA11163@bombadil.infradead.org>
References: <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
 <1537801706.195115.7.camel@acm.org>
 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
 <1537804720.195115.9.camel@acm.org>
 <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
 <1537805984.195115.14.camel@acm.org>
 <20180924185753.GA32269@bombadil.infradead.org>
 <20180925001615.GA14386@ming.t460p>
 <20180925032826.GA4110@bombadil.infradead.org>
 <4a19ac2f-82c1-db55-9b93-4005ace5e2fe@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4a19ac2f-82c1-db55-9b93-4005ace5e2fe@acm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bvanassche@acm.org>
Cc: Ming Lei <ming.lei@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Sep 24, 2018 at 09:10:43PM -0700, Bart Van Assche wrote:
> On 9/24/18 8:28 PM, Matthew Wilcox wrote:
> > [ ... ] Because if we have to
> > round all allocations below 64 bytes up to 64 bytes, [ ... ]
> Have you noticed that in another e-mail in this thread it has been explained
> why it is not necessary on x86 to align buffers allocated by kmalloc() on a
> 64-byte boundary even if these buffers are used for DMA?

Oh, so drivers which do this only break on !x86.  Yes, that'll work
out great.
