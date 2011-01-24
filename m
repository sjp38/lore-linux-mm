Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7069D6B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 12:17:37 -0500 (EST)
Message-ID: <4D3DB40B.8040102@redhat.com>
Date: Mon, 24 Jan 2011 12:16:59 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch v2] mm: fix deferred congestion timeout if preferred zone
 is not allowed
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <alpine.DEB.2.00.1101231429300.371@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1101231429300.371@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/23/2011 05:30 PM, David Rientjes wrote:

> This patch also ensures preferred_zone is from the set of allowed nodes
> when called from within direct reclaim since allocations are always
> constrained by cpusets in this context (it is blockable).
>
> Both of these uses of cpuset_current_mems_allowed are protected by
> get_mems_allowed().
>
> Signed-off-by: David Rientjes<rientjes@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
