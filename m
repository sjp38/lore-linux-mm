Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5A35C6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 12:08:15 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id uy5so8899664obc.18
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 09:08:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v2si5009874pbz.101.2014.09.05.09.08.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Sep 2014 09:08:14 -0700 (PDT)
Date: Fri, 5 Sep 2014 09:08:08 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ext4 vs btrfs performance on SSD array
Message-ID: <20140905160808.GA7967@infradead.org>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
 <20140902000822.GA20473@dastard>
 <20140902012222.GA21405@infradead.org>
 <20140903100158.34916d34@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140903100158.34916d34@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Nikolai Grigoriev <ngrigoriev@gmail.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

On Wed, Sep 03, 2014 at 10:01:58AM +1000, NeilBrown wrote:
> Do we still need maximums at all?

I don't think we do.  At least on any system I work with I have to
increase them to get good performance without any adverse effect on
throttling.

> So can we just remove the limit on max_sectors and the RAID5 stripe cache
> size?  I'm certainly keen to remove the later and just use a mempool if the
> limit isn't needed.
> I have seen reports that a very large raid5 stripe cache size can cause
> a reduction in performance.  I don't know why but I suspect it is a bug that
> should be found and fixed.
> 
> Do we need max_sectors ??

I'll send a patch to remove it and watch for the fireworks..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
