Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF7E26B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 01:58:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b9so6618596pfl.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 22:58:01 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 12si22176424pfn.27.2017.06.01.22.58.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 22:58:00 -0700 (PDT)
Date: Thu, 1 Jun 2017 23:57:59 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH -mm 05/13] block, THP: Make
 block_device_operations.rw_page support THP
Message-ID: <20170602055759.GC5909@linux.intel.com>
References: <20170525064635.2832-1-ying.huang@intel.com>
 <20170525064635.2832-6-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170525064635.2832-6-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-nvdimm@lists.01.org

On Thu, May 25, 2017 at 02:46:27PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> The .rw_page in struct block_device_operations is used by the swap
> subsystem to read/write the page contents from/into the corresponding
> swap slot in the swap device.  To support the THP (Transparent Huge
> Page) swap optimization, the .rw_page is enhanced to support to
> read/write THP if possible.
> 
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@intel.com>
> Cc: Vishal L Verma <vishal.l.verma@intel.com>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: linux-nvdimm@lists.01.org
> ---
>  drivers/block/brd.c           |  6 +++++-
>  drivers/block/zram/zram_drv.c |  2 ++
>  drivers/nvdimm/btt.c          |  4 +++-
>  drivers/nvdimm/pmem.c         | 42 +++++++++++++++++++++++++++++++-----------
>  4 files changed, 41 insertions(+), 13 deletions(-)

The changes in brd.c, zram_drv.c and pmem.c look good to me.  For those bits
you can add: 

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

I think we still want Vishal to make sure that the BTT changes are okay.  I
don't know that code well enough to know whether it's safe to throw 512 pages
at btt_[read|write]_pg().

Also, Ying, next time can you please CC me (and probably the linux-nvdimm
list) on the whole series?  It would give us more context on what the larger
change is, allow us to see the cover letter, allow us to test with all the
patches in the series, etc.  It's pretty easy for reviewers to skip over the
patches we don't care about or aren't in our area.

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
