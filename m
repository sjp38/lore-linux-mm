Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3AD706B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:11:47 -0400 (EDT)
Date: Mon, 15 Aug 2011 22:11:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] writeback: dirty rate control
Message-ID: <20110815141138.GB23601@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.878435971@intel.com>
 <20110809155046.GD6482@redhat.com>
 <1312906591.1083.43.camel@twins>
 <20110810140002.GA29724@localhost>
 <1312996226.23660.43.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312996226.23660.43.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 11, 2011 at 01:10:26AM +0800, Peter Zijlstra wrote:
> On Wed, 2011-08-10 at 22:00 +0800, Wu Fengguang wrote:
> > 
> > > Although I'm not quite sure how he keeps fairness in light of the
> > > sleep time bounding to MAX_PAUSE.
> > 
> > Firstly, MAX_PAUSE will only be applied when the dirty pages rush
> > high (dirty exceeded).  Secondly, the dirty exceeded state is global
> > to all tasks, in which case each task will sleep for MAX_PAUSE equally.
> > So the fairness is still maintained in dirty exceeded state. 
> 
> Its not immediately apparent how dirty_exceeded and MAX_PAUSE interact,
> but having everybody sleep MAX_PAUSE doesn't necessarily mean its fair,
> its only fair if they dirty at the same rate.

Yeah I forget to mention that, but when dirty_exceeded, the tasks will
typically sleep for MAX_PAUSE on every 8 pages, so resulting in the
same dirty rate :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
