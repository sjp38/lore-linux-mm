Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7686B02B3
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 07:04:18 -0400 (EDT)
Date: Mon, 26 Jul 2010 12:04:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] writeback: introduce
	writeback_control.inodes_written
Message-ID: <20100726110401.GO5300@csn.ul.ie>
References: <20100722050928.653312535@intel.com> <20100722061823.196659592@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100722061823.196659592@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:09:34PM +0800, Wu Fengguang wrote:
> Introduce writeback_control.inodes_written to count successful
> ->write_inode() calls.  A non-zero value means there are some
> progress on writeback, in which case more writeback will be tried.
> 
> This prevents aborting a background writeback work prematually when
> the current set of inodes for IO happen to be metadata-only dirty.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Seems reasonable.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
