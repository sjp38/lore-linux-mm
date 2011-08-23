Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A6D336B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:20:46 -0400 (EDT)
Date: Tue, 23 Aug 2011 19:20:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 01/13] fs: Use a common define for inode slab caches
Message-ID: <20110823092041.GX3162@dastard>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-2-git-send-email-david@fromorbit.com>
 <20110823091307.GA21492@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823091307.GA21492@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

On Tue, Aug 23, 2011 at 05:13:07AM -0400, Christoph Hellwig wrote:
> On Tue, Aug 23, 2011 at 06:56:14PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > All inode slab cache initialisation calls need to use specific flags
> > so that certain core functionality works correctly (e.g. reclaimable
> > memory accounting). Some of these flags are used inconsistently
> > across different filesystems, so inode cache slab behaviour can vary
> > according to filesystem type.
> > 
> > Wrap all the SLAB_* flags relevant to inode caches up into a single
> > SLAB_INODES flag and convert all the inode caches to use the new
> > flag.
> 
> Why do we keep the SLAB_HWCACHE_ALIGN flag for some filesystems?

I didn't touch that one, mainly because I think that there are
different reasons for wanting cacheline alignment. e.g. a filesystem
aimed primarily at embedded systms with slow CPUs and little memory
doesn't want to waste memory on cacheline alignment....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
