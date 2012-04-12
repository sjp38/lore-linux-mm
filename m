Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E1E1D6B004A
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 18:36:05 -0400 (EDT)
Date: Thu, 12 Apr 2012 15:36:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
Message-Id: <20120412153603.fe320f54.akpm@linux-foundation.org>
In-Reply-To: <1334253782-22755-1-git-send-email-yinghan@google.com>
References: <1334253782-22755-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, 12 Apr 2012 11:03:02 -0700
Ying Han <yinghan@google.com> wrote:

> It is always confusing on stat "pgsteal" where it counts both direct
> reclaim as well as background reclaim. However, we have "kswapd_steal"
> which also counts background reclaim value.
> 
> This patch fixes it and also makes it match the existng "pgscan_" stats.
> 
> Test:
> pgsteal_kswapd_dma32 447623
> pgsteal_kswapd_normal 42272677
> pgsteal_kswapd_movable 0
> pgsteal_direct_dma32 2801
> pgsteal_direct_normal 44353270
> pgsteal_direct_movable 0
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/vm_event_item.h |    5 +++--
>  mm/vmscan.c                   |   11 ++++++++---
>  mm/vmstat.c                   |    4 ++--

I was going to have a big whine about the failure to update the
/proc/vmstat documentation.  But we don't have any /proc/vmstat
documentation.  That was a sneaky labor-saving device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
