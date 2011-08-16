Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 246F26B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 03:22:56 -0400 (EDT)
Date: Tue, 16 Aug 2011 15:22:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110816072251.GA12264@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022329.063575688@intel.com>
 <20110816071709.GA1302@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110816071709.GA1302@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > +	if (!bdi->dirty_exceeded)
> > +		ratelimit = current->nr_dirtied_pause;
> > +	else
> > +		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));
> 
> Usage of ratelimit before init?
> 
> Maybe:
> 
> 	ratelimit = current->nr_dirtied_pause;
> 	if (bdi->dirty_exceeded)
> 		ratelimit = min(ratelimit, 32 >> (PAGE_SHIFT - 10));

Good catch, thanks! That's indeed the original form. I changed it to
make the code more aligned...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
