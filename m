Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id CF58C6B13F0
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 09:55:50 -0500 (EST)
Message-ID: <4F36816A.6030609@redhat.com>
Date: Sat, 11 Feb 2012 09:55:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com> <20120208093120.GA18993@localhost> <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com> <20120210114706.GA4704@localhost> <20120211124445.GA10826@localhost>
In-Reply-To: <20120211124445.GA10826@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On 02/11/2012 07:44 AM, Wu Fengguang wrote:

> Note that it's data for XFS. ext4 seems to have some problem with the
> workload: the majority pages are found to be writeback pages, and the
> flusher ends up blocking on the unconditional wait_on_page_writeback()
> in write_cache_pages_da() from time to time...
>
> XXX: commit NFS unstable pages via write_inode()
> XXX: the added congestion_wait() may be undesirable in some situations

Even with these caveats, this seems to be the right way forward.

> CC: Jan Kara<jack@suse.cz>
> CC: Mel Gorman<mgorman@suse.de>
> CC: Rik van Riel<riel@redhat.com>
> CC: Greg Thelen<gthelen@google.com>
> CC: Minchan Kim<minchan.kim@gmail.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
