Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4606B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 05:50:15 -0400 (EDT)
Received: by gyg13 with SMTP id 13so3130842gyg.14
        for <linux-mm@kvack.org>; Fri, 29 Jul 2011 02:50:13 -0700 (PDT)
Date: Fri, 29 Jul 2011 18:50:05 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/8] Reduce filesystem writeback from page reclaim v2
Message-ID: <20110729095005.GH1843@barrios-desktop>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <20110727161821.GA1738@barrios-desktop>
 <20110728113852.GN3010@suse.de>
 <20110729094816.GG1843@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110729094816.GG1843@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Lutomirski <luto@mit.edu>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

Sorry for missing Ccing.

On Fri, Jul 29, 2011 at 06:48:16PM +0900, Minchan Kim wrote:
> On Thu, Jul 28, 2011 at 12:38:52PM +0100, Mel Gorman wrote:
> > On Thu, Jul 28, 2011 at 01:18:21AM +0900, Minchan Kim wrote:
> > > On Thu, Jul 21, 2011 at 05:28:42PM +0100, Mel Gorman wrote:
> > > > Note how preventing kswapd reclaiming dirty pages pushes up its CPU
> 
> <snip>
> 
> > > > usage as it scans more pages but it does not get excessive due to
> > > > the throttling.
> > > 
> > > Good to hear.
> > > The concern of this patchset was early OOM kill with too many scanning.
> > > I can throw such concern out from now on.
> > > 
> > 
> > At least, I haven't been able to trigger a premature OOM.
> 
> AFAIR, Andrew had a premature OOM problem[1] but I couldn't track down at that time.
> I think this patch series might solve his problem. Although it doesn't, it should not accelerate
> his problem, at least.
> 
> Andrew, Could you test this patchset?
> 
> [1] https://lkml.org/lkml/2011/5/25/415
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
