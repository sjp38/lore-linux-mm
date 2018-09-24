Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 144F78E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:06:29 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 123-v6so22829389qkl.3
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:06:29 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id d6-v6si3194027qvb.143.2018.09.24.09.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 09:06:28 -0700 (PDT)
Date: Mon, 24 Sep 2018 16:06:28 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
In-Reply-To: <20180921130504.GA22551@lst.de>
Message-ID: <010001660c54fb65-b9d3a770-6678-40d0-8088-4db20af32280-000000@email.amazonses.com>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com> <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com> <20180921130504.GA22551@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>

On Fri, 21 Sep 2018, Christoph Hellwig wrote:

> On Fri, Sep 21, 2018 at 03:04:18PM +0200, Vitaly Kuznetsov wrote:
> > Christoph Hellwig <hch@lst.de> writes:
> >
> > > On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
> > >> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
> > >> yes, is it a stable rule?
> > >
> > > This is the assumption in a lot of the kernel, so I think if somethings
> > > breaks this we are in a lot of pain.
> >
> > It seems that SLUB debug breaks this assumption. Kernel built with
> >
> > CONFIG_SLUB_DEBUG=y
> > CONFIG_SLUB=y
> > CONFIG_SLUB_DEBUG_ON=y
>
> Looks like we should fix SLUB debug then..

Nope. We need to not make unwarranted assumptions. Alignment is guaranteed
to ARCH_KMALLOC_MINALIGN for kmalloc requests. Fantasizing about
alighments and guessing from alignments that result on a particular
hardware and slab configuration that these are general does not work.
