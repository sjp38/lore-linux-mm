Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A588C6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 02:16:10 -0400 (EDT)
Date: Wed, 24 Aug 2011 02:16:02 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/13] fs: Use a common define for inode slab caches
Message-ID: <20110824061602.GA24077@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-2-git-send-email-david@fromorbit.com>
 <20110823091307.GA21492@infradead.org>
 <20110823092041.GX3162@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823092041.GX3162@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

On Tue, Aug 23, 2011 at 07:20:41PM +1000, Dave Chinner wrote:
> > Why do we keep the SLAB_HWCACHE_ALIGN flag for some filesystems?
> 
> I didn't touch that one, mainly because I think that there are
> different reasons for wanting cacheline alignment. e.g. a filesystem
> aimed primarily at embedded systms with slow CPUs and little memory
> doesn't want to waste memory on cacheline alignment....

A little grepping shows jffs2 is a counter example, because it exactly
wants SLAB_HWCACHE_ALIGN to avoid issues with mtd dma.

I'm fine with defering this for now, but the state of using
SLAB_HWCACHE_ALIGN or not is just as much as mess as the rest of the
inode slab flags was.  I'd go as far as calling the whole existance of
most slab flags an utter mess, but that is another fight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
