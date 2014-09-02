Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D25456B0035
	for <linux-mm@kvack.org>; Mon,  1 Sep 2014 21:22:29 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so7165617pdj.7
        for <linux-mm@kvack.org>; Mon, 01 Sep 2014 18:22:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id qf4si3317507pbb.163.2014.09.01.18.22.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Sep 2014 18:22:26 -0700 (PDT)
Date: Mon, 1 Sep 2014 18:22:22 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ext4 vs btrfs performance on SSD array
Message-ID: <20140902012222.GA21405@infradead.org>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
 <20140902000822.GA20473@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140902000822.GA20473@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Nikolai Grigoriev <ngrigoriev@gmail.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

On Tue, Sep 02, 2014 at 10:08:22AM +1000, Dave Chinner wrote:
> Pretty obvious difference: avgrq-sz. btrfs is doing 512k IOs, ext4
> and XFS are doing is doing 128k IOs because that's the default block
> device readahead size.  'blockdev --setra 1024 /dev/sdd' before
> mounting the filesystem will probably fix it.

Btw, it's really getting time to make Linux storage fs work out the
box.  There's way to many things that are stupid by default and we
require everyone to fix up manually:

 - the ridiculously low max_sectors default
 - the very small max readahead size
 - replacing cfq with deadline (or noop)
 - the too small RAID5 stripe cache size

and probably a few I forgot about.  It's time to make things perform
well out of the box..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
