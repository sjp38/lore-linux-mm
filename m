Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B69976B02AB
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 10:55:15 -0400 (EDT)
Received: by pzk33 with SMTP id 33so2851715pzk.14
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 07:56:22 -0700 (PDT)
Date: Thu, 5 Aug 2010 23:56:06 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/6] writeback: kill writeback_control.more_io
Message-ID: <20100805145606.GA3083@barrios-desktop>
References: <20100722050928.653312535@intel.com>
 <20100722061822.763629019@intel.com>
 <20100801153424.GA8204@barrios-desktop>
 <20100805145053.GA6161@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805145053.GA6161@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 10:50:53PM +0800, Wu Fengguang wrote:
> > include/trace/events/ext4.h also have more_io field. 
> 
> I didn't find it in linux-next. What's your kernel version?

I used mmotm-07-29. 

> 
> Thanks,
> Fengguang

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
