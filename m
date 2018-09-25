Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31D3A8E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 00:10:48 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p8-v6so2711137pfn.23
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 21:10:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b14-v6sor246483plk.57.2018.09.24.21.10.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 21:10:46 -0700 (PDT)
Subject: Re: block: DMA alignment of IO buffer allocated from slab
References: <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
 <1537801706.195115.7.camel@acm.org>
 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
 <1537804720.195115.9.camel@acm.org>
 <10c706fd-2252-f11b-312e-ae0d97d9a538@virtuozzo.com>
 <1537805984.195115.14.camel@acm.org>
 <20180924185753.GA32269@bombadil.infradead.org>
 <20180925001615.GA14386@ming.t460p>
 <20180925032826.GA4110@bombadil.infradead.org>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <4a19ac2f-82c1-db55-9b93-4005ace5e2fe@acm.org>
Date: Mon, 24 Sep 2018 21:10:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180925032826.GA4110@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Ming Lei <ming.lei@redhat.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 9/24/18 8:28 PM, Matthew Wilcox wrote:
> [ ... ] Because if we have to
> round all allocations below 64 bytes up to 64 bytes, [ ... ]
Have you noticed that in another e-mail in this thread it has been 
explained why it is not necessary on x86 to align buffers allocated by 
kmalloc() on a 64-byte boundary even if these buffers are used for DMA?

Bart.
