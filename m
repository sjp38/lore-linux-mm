Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DB65C8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:37:04 -0400 (EDT)
Date: Thu, 21 Apr 2011 16:36:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421063659.GH1814@dastard>
References: <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
 <20110420025321.GA14398@localhost>
 <20110421004547.GD1814@dastard>
 <20110421020617.GB12191@localhost>
 <20110421030152.GG1814@dastard>
 <20110421035954.GA15461@localhost>
 <20110421041010.GA18710@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421041010.GA18710@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 12:10:11PM +0800, Wu Fengguang wrote:
> > > Still, given wb_writeback() is the only caller of both
> > > __writeback_inodes_sb and writeback_inodes_wb(), I'm wondering if
> > > moving the queue_io calls up into wb_writeback() would clean up this
> > > logic somewhat. I think Jan mentioned doing something like this as
> > > well elsewhere in the thread...
> > 
> > Unfortunately they call queue_io() inside the lock..
> 
> OK, let's try moving up the lock too. Do you like this change? :)

Yes, very much ;)

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
