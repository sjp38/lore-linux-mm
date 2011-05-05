Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 326606B0027
	for <linux-mm@kvack.org>; Thu,  5 May 2011 12:37:16 -0400 (EDT)
Date: Thu, 5 May 2011 18:37:08 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/6] writeback: refill b_io iff empty
Message-ID: <20110505163708.GN5323@quack.suse.cz>
References: <20110420080336.441157866@intel.com>
 <20110420080918.560499032@intel.com>
 <20110504073931.GA22675@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504073931.GA22675@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-11 15:39:31, Wu Fengguang wrote:
> To help understand the behavior change, I wrote the writeback_queue_io
> trace event, and found very different patterns between
> - vanilla kernel
> - this patchset plus the sync livelock fixes
> 
> Basically the vanilla kernel each time pulls a random number of inodes
> from b_dirty, while the patched kernel tends to pull a fixed number of
> inodes (enqueue=1031) from b_dirty. The new behavior is very interesting...
  This regularity is really strange. Did you have a chance to look more into
it? I find it highly unlikely that there would be exactly 1031 dirty inodes
in b_dirty list every time you call move_expired_inodes()...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
