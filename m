Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DD8B96006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 06:53:25 -0400 (EDT)
Date: Mon, 26 Jul 2010 11:53:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] writeback: kill writeback_control.more_io
Message-ID: <20100726105308.GL5300@csn.ul.ie>
References: <20100722050928.653312535@intel.com> <20100722061822.763629019@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100722061822.763629019@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:09:31PM +0800, Wu Fengguang wrote:
> When wbc.more_io was first introduced, it indicates whether there are
> at least one superblock whose s_more_io contains more IO work. Now with
> the per-bdi writeback, it can be replaced with a simple b_more_io test.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

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
