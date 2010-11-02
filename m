Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AA71F8D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 21:55:27 -0400 (EDT)
Received: by iwn38 with SMTP id 38so7042059iwn.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 18:55:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101101203947.GB7309@localhost>
References: <20100913123110.372291929@intel.com>
	<20100913130149.994322762@intel.com>
	<20100914124033.GA4874@quack.suse.cz>
	<20101101121408.GB9006@localhost>
	<20101101152149.GA12741@infradead.org>
	<20101101203947.GB7309@localhost>
Date: Tue, 2 Nov 2010 10:55:25 +0900
Message-ID: <AANLkTi=iLAJmUozo1hkuGZbNYXi08fjQemLEg8_nw91O@mail.gmail.com>
Subject: Re: [PATCH 1/2 v2] writeback: integrated background writeback work
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 2, 2010 at 5:39 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
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
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
