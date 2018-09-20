Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACCF8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 02:31:30 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id l15-v6so7999452wrp.8
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 23:31:30 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w130-v6si1041883wmf.64.2018.09.19.23.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 23:31:29 -0700 (PDT)
Date: Thu, 20 Sep 2018 08:31:29 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180920063129.GB12913@lst.de>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>

On Wed, Sep 19, 2018 at 05:15:43PM +0800, Ming Lei wrote:
> 1) does kmalloc-N slab guarantee to return N-byte aligned buffer?  If
> yes, is it a stable rule?

This is the assumption in a lot of the kernel, so I think if somethings
breaks this we are in a lot of pain.
