Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9E4A28D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 21:57:27 -0400 (EDT)
Received: by iwn38 with SMTP id 38so7044195iwn.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 18:57:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101101122252.GA10637@localhost>
References: <20100913123110.372291929@intel.com>
	<20100913130149.994322762@intel.com>
	<20100914124033.GA4874@quack.suse.cz>
	<20101101121408.GB9006@localhost>
	<20101101122252.GA10637@localhost>
Date: Tue, 2 Nov 2010 10:57:26 +0900
Message-ID: <AANLkTin3gO5BpT25u_4q62EVcD=5awWOeKf3BBoLiHUq@mail.gmail.com>
Subject: Re: [PATCH 2/2] writeback: stop background/kupdate works from
 livelocking other works
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 1, 2010 at 9:22 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> From: Jan Kara <jack@suse.cz>
>
> Background writeback are easily livelockable (from a definition of their
> target). This is inconvenient because it can make sync(1) stall forever waiting
> on its queued work to be finished. Generally, when a flusher thread has
> some work queued, someone submitted the work to achieve a goal more specific
> than what background writeback does. So it makes sense to give it a priority
> over a generic page cleaning.
>
> Thus we interrupt background writeback if there is some other work to do. We
> return to the background writeback after completing all the queued work.
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
