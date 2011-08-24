Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 263BD6B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 23:16:09 -0400 (EDT)
Date: Wed, 24 Aug 2011 11:16:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110824031603.GA30873@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022328.811348370@intel.com>
 <20110816194112.GA25517@quack.suse.cz>
 <20110817132347.GA6628@localhost>
 <20110817202414.GK9959@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110817202414.GK9959@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > > > +	x_intercept = setpoint + 2 * span;
>    ^^ BTW, why do you have 2*span here? It can result in x_intercept being
> ~3*bdi_thresh... So maybe you should use bdi_thresh/2 in the computation of
> span?

OK, I'll follow your suggestion to use

        span = 8 * write_bw, for single bdi case 
        span = bdi_thresh, for JBOD case
        x_intercept = setpoint + span;

It does make sense to squeeze the bdi_dirty fluctuation range a bit by
doubling span and making the control line more sharp.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
