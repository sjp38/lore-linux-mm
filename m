Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFE76B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 13:20:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e185so4488059wmg.5
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 10:20:56 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g89si563941wrd.274.2018.04.09.10.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 10:20:55 -0700 (PDT)
Date: Mon, 9 Apr 2018 19:20:54 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 6/7] block: consistently use GFP_NOIO instead of
	__GFP_NORECLAIM
Message-ID: <20180409172054.GA5697@lst.de>
References: <20180409153916.23901-1-hch@lst.de> <20180409153916.23901-7-hch@lst.de> <20180409160354.GD11756@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409160354.GD11756@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, axboe@kernel.dk, Bart.VanAssche@wdc.com, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 09, 2018 at 09:03:54AM -0700, Matthew Wilcox wrote:
> > @@ -499,7 +499,7 @@ int sg_scsi_ioctl(struct request_queue *q, struct gendisk *disk, fmode_t mode,
> >  		break;
> >  	}
> >  
> > -	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, __GFP_RECLAIM)) {
> > +	if (bytes && blk_rq_map_kern(q, rq, buffer, bytes, GFP_NOIO)) {
> 
> We don't seem to have grabbed any locks between the line which allocates
> memory using GFP_USER (line 446) and here, so I don't see why we should
> prohibit I/O?

No change of behavior for this patch.  If you care deeply about using
GFP_KERNEL here send an incremental patch that I can add to the end of
the series.
