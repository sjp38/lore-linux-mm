Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D47F8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 09:05:03 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id g25-v6so2413691wmh.6
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 06:05:03 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 132-v6si2841873wmh.90.2018.09.21.06.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 06:05:01 -0700 (PDT)
Date: Fri, 21 Sep 2018 15:05:04 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180921130504.GA22551@lst.de>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com> <20180920063129.GB12913@lst.de> <87h8ij0zot.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87h8ij0zot.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>, Christoph Lameter <cl@linux.com>

On Fri, Sep 21, 2018 at 03:04:18PM +0200, Vitaly Kuznetsov wrote:
> Christoph Hellwig <hch@lst.de> writes:
> 
> > On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
> >> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
> >> yes, is it a stable rule?
> >
> > This is the assumption in a lot of the kernel, so I think if somethings
> > breaks this we are in a lot of pain.
> 
> It seems that SLUB debug breaks this assumption. Kernel built with
> 
> CONFIG_SLUB_DEBUG=y
> CONFIG_SLUB=y
> CONFIG_SLUB_DEBUG_ON=y

Looks like we should fix SLUB debug then..
