Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F08A76B02AC
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:26:52 -0400 (EDT)
Date: Thu, 5 Aug 2010 23:26:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: kill writeback_control.more_io
Message-ID: <20100805152646.GA10385@localhost>
References: <20100722050928.653312535@intel.com>
 <20100722061822.763629019@intel.com>
 <20100801153424.GA8204@barrios-desktop>
 <20100805145053.GA6161@localhost>
 <20100805145606.GA3083@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805145606.GA3083@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 05, 2010 at 10:56:06PM +0800, Minchan Kim wrote:
> On Thu, Aug 05, 2010 at 10:50:53PM +0800, Wu Fengguang wrote:
> > > include/trace/events/ext4.h also have more_io field. 
> > 
> > I didn't find it in linux-next. What's your kernel version?
> 
> I used mmotm-07-29. 

Heh it's in linux-next too -- I didn't find the field because the
chunk to remove it slipped into a previous patch..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
