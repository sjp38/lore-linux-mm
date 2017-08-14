Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDC046B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:48:40 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i192so125206801pgc.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 01:48:40 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x1si4321218plm.825.2017.08.14.01.48.39
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 01:48:39 -0700 (PDT)
Date: Mon, 14 Aug 2017 17:48:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170814084837.GF26913@bbox>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-3-git-send-email-minchan@kernel.org>
 <20170808124959.GB31390@bombadil.infradead.org>
 <20170808132904.GC31390@bombadil.infradead.org>
 <20170809015113.GB32338@bbox>
 <20170809023122.GF31390@bombadil.infradead.org>
 <20170809024150.GA32471@bbox>
 <20170810030433.GG31390@bombadil.infradead.org>
 <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
 <20170811104615.GA14397@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811104615.GA14397@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

Hi Christoph,

On Fri, Aug 11, 2017 at 12:46:15PM +0200, Christoph Hellwig wrote:
> On Wed, Aug 09, 2017 at 08:06:24PM -0700, Dan Williams wrote:
> > I like it, but do you think we should switch to sbvec[<constant>] to
> > preclude pathological cases where nr_pages is large?
> 
> Yes, please.

Still, I don't understand how sbvec[nr_pages] with on-stack bio in
do_mpage_readpage can help the performance.

IIUC, do_mpage_readpage works with page-base. IOW, it passes just one
page, not multiple pages so if we use on-stack bio, we just add *a page*
via bio_add_page and submit the bio before the function returning.

So, rather than sbvec[1], why de we need sbvec[nr_pages]?

Please, let me open my eyes. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
