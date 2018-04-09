Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1D306B0006
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 13:22:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v191so5645728wmd.1
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 10:22:00 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 4si569314wrh.100.2018.04.09.10.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 10:21:59 -0700 (PDT)
Date: Mon, 9 Apr 2018 19:21:58 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 7/7] block: use GFP_KERNEL for allocations from
	blk_get_request
Message-ID: <20180409172158.GB5697@lst.de>
References: <20180409153916.23901-1-hch@lst.de> <20180409153916.23901-8-hch@lst.de> <20180409165203.GE11756@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409165203.GE11756@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, axboe@kernel.dk, Bart.VanAssche@wdc.com, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 09, 2018 at 09:52:03AM -0700, Matthew Wilcox wrote:
> On Mon, Apr 09, 2018 at 05:39:16PM +0200, Christoph Hellwig wrote:
> > blk_get_request is used for pass-through style I/O and thus doesn't need
> > GFP_NOIO.
> 
> Obviously GFP_KERNEL is a big improvement over GFP_NOIO!  But can we take
> it all the way to GFP_USER, if this is always done in the ioctl path
> (which it seems to be, except for nfsd, which presumably won't have
> a cpuset memory allocation policy ... and if it did, the admin might
> appreciate it honouring said policy).

GFP_USER claims to be for allocations mapped into userspace, and except
for a few outliers that is how we use it.  I see no reason to change
that here.
