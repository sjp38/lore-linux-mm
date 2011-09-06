Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9D36B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 11:47:29 -0400 (EDT)
Subject: Re: [PATCH 05/18] writeback: per task dirty rate limit
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 06 Sep 2011 17:47:10 +0200
In-Reply-To: <20110904020915.240747479@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020915.240747479@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315324030.14232.14.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
>  /*
> + * After a task dirtied this many pages, balance_dirty_pages_ratelimited=
_nr()
> + * will look to see if it needs to start dirty throttling.
> + *
> + * If dirty_poll_interval is too low, big NUMA machines will call the ex=
pensive
> + * global_page_state() too often. So scale it near-sqrt to the safety ma=
rgin
> + * (the number of pages we may dirty without exceeding the dirty limits)=
.
> + */
> +static unsigned long dirty_poll_interval(unsigned long dirty,
> +                                        unsigned long thresh)
> +{
> +       if (thresh > dirty)
> +               return 1UL << (ilog2(thresh - dirty) >> 1);
> +
> +       return 1;
> +}

Where does that sqrt come from?=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
