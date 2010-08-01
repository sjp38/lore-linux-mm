Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 313B36B02A7
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 11:23:13 -0400 (EDT)
Received: by pwi8 with SMTP id 8so1260359pwi.14
        for <linux-mm@kvack.org>; Sun, 01 Aug 2010 08:23:11 -0700 (PDT)
Date: Mon, 2 Aug 2010 00:23:02 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/6] writeback: pass writeback_control down to
 move_expired_inodes()
Message-ID: <20100801152302.GB8158@barrios-desktop>
References: <20100722050928.653312535@intel.com>
 <20100722061822.484666925@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722061822.484666925@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:09:29PM +0800, Wu Fengguang wrote:
> This is to prepare for moving the dirty expire policy to move_expired_inodes().
> No behavior change.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
