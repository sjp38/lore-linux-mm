Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D184D6B0169
	for <linux-mm@kvack.org>; Sat, 20 Aug 2011 15:33:59 -0400 (EDT)
Date: Sat, 20 Aug 2011 20:33:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7] Reduce filesystem writeback from page reclaim v3
Message-ID: <20110820193351.GA8349@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
 <20110818165420.0a7aabb5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110818165420.0a7aabb5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Aug 18, 2011 at 04:54:20PM -0700, Andrew Morton wrote:
> On Wed, 10 Aug 2011 11:47:13 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > The new problem is that
> > reclaim has very little control over how long before a page in a
> > particular zone or container is cleaned which is discussed later.
> 
> Confused - where was this discussed?  Please tell us more about
> this problem and how it was addressed.
> 

I'm currently on holiday. I am only online checking train timetables.
I'll be back online properly on August 30th.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
