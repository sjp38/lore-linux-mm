Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04F436B025F
	for <linux-mm@kvack.org>; Sun, 13 Aug 2017 21:39:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u199so109105211pgb.13
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 18:39:16 -0700 (PDT)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id s69si3505966pgs.647.2017.08.13.18.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Aug 2017 18:39:15 -0700 (PDT)
Received: by mail-pg0-x22e.google.com with SMTP id v77so36838751pgb.3
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 18:39:15 -0700 (PDT)
Date: Mon, 14 Aug 2017 10:39:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 1/7] zram: set BDI_CAP_STABLE_WRITES once
Message-ID: <20170814013930.GA603@jagdpanzerIV.localdomain>
References: <1502428647-28928-1-git-send-email-minchan@kernel.org>
 <1502428647-28928-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502428647-28928-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Senozhatsky <sergey.senozhatsky@gmail.com>, Ilya Dryomov <idryomov@gmail.com>

On (08/11/17 14:17), Minchan Kim wrote:
> [1] fixed weird thing(i.e., reset BDI_CAP_STABLE_WRITES flag
> unconditionally whenever revalidat_disk is called) so zram doesn't
> need to reset the flag any more whenever revalidating the bdev.
> Instead, set the flag just once when the zram device is created.
> 
> It shouldn't change any behavior.
> 
> [1] 19b7ccf8651d, block: get rid of blk_integrity_revalidate()
> Cc: Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Ilya Dryomov <idryomov@gmail.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
