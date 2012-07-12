Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 9A9E46B004D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 22:18:08 -0400 (EDT)
Date: Wed, 11 Jul 2012 19:21:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty
 pages
Message-Id: <20120711192106.b6b8232f.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
	<20120619150014.1ebc108c.akpm@linux-foundation.org>
	<20120620101119.GC5541@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Wed, 11 Jul 2012 18:57:43 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> --- 3.5-rc6-mm1/mm/vmscan.c	2012-07-11 14:42:13.668335884 -0700
> +++ linux/mm/vmscan.c	2012-07-11 16:01:20.712814127 -0700
> @@ -726,7 +726,8 @@ static unsigned long shrink_page_list(st
>  			 * writeback from reclaim and there is nothing else to
>  			 * reclaim.
>  			 */
> -			if (!global_reclaim(sc) && PageReclaim(page))
> +			if (!global_reclaim(sc) && PageReclaim(page) &&
> +					may_enter_fs)
>  				wait_on_page_writeback(page);
>  			else {
>  				nr_writeback++;

um, that may_enter_fs test got removed because nobody knew why it was
there.  Nobody knew why it was there because it was undocumented.  Do
you see where I'm going with this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
