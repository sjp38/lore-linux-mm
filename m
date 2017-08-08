Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03F5F6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:13:43 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k190so27686946pge.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:13:42 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l27si529925pfg.524.2017.08.08.01.13.41
        for <linux-mm@kvack.org>;
        Tue, 08 Aug 2017 01:13:42 -0700 (PDT)
Date: Tue, 8 Aug 2017 17:13:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 5/6] zram: remove zram_rw_page
Message-ID: <20170808081338.GA30908@bbox>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-6-git-send-email-minchan@kernel.org>
 <20170808070226.GC7765@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808070226.GC7765@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Sergey,

On Tue, Aug 08, 2017 at 04:02:26PM +0900, Sergey Senozhatsky wrote:
> On (08/08/17 15:50), Minchan Kim wrote:
> > With on-stack-bio, rw_page interface doesn't provide a clear performance
> > benefit for zram and surely has a maintenance burden, so remove the
> > last user to remove rw_page completely.
> 
> OK, never really liked it, I think we had that conversation before.
> 
> as far as I remember, zram_rw_page() was the reason we had to do some
> tricks with init_lock to make lockdep happy. may be now we can "simplify"
> the things back.

I cannot remember. Blame my brain. ;-)

Anyway, it's always welcome to make thing simple.
Could you send a patch after settle down this patchset?

> 
> 
> > Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
