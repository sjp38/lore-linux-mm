Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEA166B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 03:37:46 -0400 (EDT)
Date: Wed, 27 Jul 2011 08:37:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/8] Reduce filesystem writeback from page reclaim v2
Message-ID: <20110727073737.GG3010@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <CAEwNFnA_OGUYfCQrLCMt9NuU0O0ftWWBB4_Si8NypKyaeuRg2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAEwNFnA_OGUYfCQrLCMt9NuU0O0ftWWBB4_Si8NypKyaeuRg2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

On Wed, Jul 27, 2011 at 01:32:17PM +0900, Minchan Kim wrote:
> >
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110721
> >
> > Unfortunately, the volume of data is excessive but here is a partial
> > summary of what was interesting for XFS.
> 
> Could you clarify the notation?
> 1P :  1 Processor?
> 512M: system memory size?
> 2X , 4X, 16X: the size of files created during test
> 

1P   == 1 Processor
512M == 512M RAM (mem=512M)
2X   == 2 x NUM_CPU fsmark threads

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
