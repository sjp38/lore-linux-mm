Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9673D6B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 14:08:48 -0400 (EDT)
Message-ID: <4F871A26.1000600@redhat.com>
Date: Thu, 12 Apr 2012 14:08:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
References: <1334253782-22755-1-git-send-email-yinghan@google.com>
In-Reply-To: <1334253782-22755-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 04/12/2012 02:03 PM, Ying Han wrote:
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
> Signed-off-by: Ying Han<yinghan@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
