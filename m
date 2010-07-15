Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 20E8C6B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:10:28 -0400 (EDT)
Date: Thu, 15 Jul 2010 14:10:25 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/3] xfs: convert inode shrinker to per-filesystem
 contexts
Message-ID: <20100715181025.GB14554@infradead.org>
References: <1279194418-16119-1-git-send-email-david@fromorbit.com>
 <1279194418-16119-3-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279194418-16119-3-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 15, 2010 at 09:46:57PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now the shrinker passes us a context, wire up a shrinker context per
> filesystem. This allows us to remove the global mount list and the
> locking problems that introduced. It also means that a shrinker call
> does not need to traverse clean filesystems before finding a
> filesystem with reclaimable inodes.  This significantly reduces
> scanning overhead when lots of filesystems are present.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/linux-2.6/xfs_super.c |    2 -
>  fs/xfs/linux-2.6/xfs_sync.c  |   62 +++++++++--------------------------------
>  fs/xfs/linux-2.6/xfs_sync.h  |    2 -
>  fs/xfs/xfs_mount.h           |    2 +-
>  4 files changed, 15 insertions(+), 53 deletions(-)

And makes the code a lot simpler and more obvious.


Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
