Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 700E08E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:58:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m3-v6so10142506plt.9
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:58:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16-v6sor1003527pgk.228.2018.09.24.08.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 08:58:43 -0700 (PDT)
Message-ID: <1537804720.195115.9.camel@acm.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 24 Sep 2018 08:58:40 -0700
In-Reply-To: <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
References: 
	<CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
	 <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
	 <20180923224206.GA13618@ming.t460p>
	 <38c03920-0fd0-0a39-2a6e-70cd8cb4ef34@virtuozzo.com>
	 <20a20568-5089-541d-3cee-546e549a0bc8@acm.org>
	 <12eee877-affa-c822-c9d5-fda3aa0a50da@virtuozzo.com>
	 <1537801706.195115.7.camel@acm.org>
	 <c844c598-be1d-bef4-fb99-09cf99571fd7@virtuozzo.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Ming Lei <ming.lei@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, 2018-09-24 at 18:52 +-0300, Andrey Ryabinin wrote:
+AD4 Yes, with CONFIG+AF8-DEBUG+AF8-SLAB+AD0-y, CONFIG+AF8-SLUB+AF8-DEBUG+AF8-ON+AD0-y kmalloc() guarantees
+AD4 that result is aligned on ARCH+AF8-KMALLOC+AF8-MINALIGN boundary.

Had you noticed that Vitaly Kuznetsov showed that this is not the case? See
also https://lore.kernel.org/lkml/87h8ij0zot.fsf+AEA-vitty.brq.redhat.com/.

Thanks,

Bart.
