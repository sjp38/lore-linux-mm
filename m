Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACA726B00BE
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 08:01:59 -0400 (EDT)
Date: Fri, 5 Nov 2010 13:01:40 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2 v2] writeback: integrated background writeback work
Message-ID: <20101105120139.GB23393@cmpxchg.org>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
 <20101101121408.GB9006@localhost>
 <20101101152149.GA12741@infradead.org>
 <20101101203947.GB7309@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101101203947.GB7309@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2010 at 04:39:47AM +0800, Wu Fengguang wrote:
> From: Jan Kara <jack@suse.cz>
> 
> Check whether background writeback is needed after finishing each work.
> 
> When bdi flusher thread finishes doing some work check whether any kind
> of background writeback needs to be done (either because
> dirty_background_ratio is exceeded or because we need to start flushing
> old inodes). If so, just do background write back.
> 
> This way, bdi_start_background_writeback() just needs to wake up the
> flusher thread. It will do background writeback as soon as there is no
> other work.
> 
> This is a preparatory patch for the next patch which stops background
> writeback as soon as there is other work to do.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
