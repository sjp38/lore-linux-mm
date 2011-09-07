Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 06A616B016E
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 05:32:54 -0400 (EDT)
Date: Wed, 7 Sep 2011 17:06:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 15/18] writeback: charge leaked page dirties to active
 tasks
Message-ID: <20110907090615.GA13841@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020916.588150387@intel.com>
 <1315325796.14232.20.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315325796.14232.20.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 07, 2011 at 12:16:36AM +0800, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > The solution is to charge the pages dirtied by the exited gcc to the
> > other random gcc/dd instances.
> 
> random dirtying task, seeing it lacks a !strcmp(t->comm, "gcc") || !
> strcmp(t->comm, "dd") clause.

OK.

> >  It sounds not perfect, however should
> > behave good enough in practice. 
> 
> Seeing as that throttled tasks aren't actually running so those that are
> running are more likely to pick it up and get throttled, therefore
> promoting an equal spread.. ?

Exactly. Let me write that into changelog :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
