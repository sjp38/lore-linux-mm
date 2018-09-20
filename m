Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60B9D8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 02:32:26 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s18-v6so4739266wrw.22
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 23:32:26 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e14-v6si23198690wrw.379.2018.09.19.23.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 23:32:25 -0700 (PDT)
Date: Thu, 20 Sep 2018 08:32:26 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180920063226.GC12913@lst.de>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com> <877ejh3jv0.fsf@vitty.brq.redhat.com> <20180919100256.GD23172@ming.t460p> <8736u53fij.fsf@vitty.brq.redhat.com> <20180920012836.GA27645@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180920012836.GA27645@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>

On Thu, Sep 20, 2018 at 09:28:37AM +0800, Ming Lei wrote:
> > has e.g. PAGE_SIZE alignment requirement (this would likely imply that
> > it's sector size is also not 512 I guess)?
> 
> Yeah, that can be true if one controller has 4k-byte sector size, also
> its DMA alignment is 4K. But there shouldn't be cases in which the two
> doesn't match.

The general block storage worlds is that devices always need to have
an alignment requirement <= minimum LBAs size.  If they don't they'll
need to bounce buffer (in the driver!).
