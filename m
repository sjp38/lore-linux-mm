Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id EBAD86B00E7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:21:25 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 684F33EE0BB
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:21:24 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E0A345DEB2
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:21:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3525C45DE9E
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:21:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B6C1DB803F
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:21:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3986E18002
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:21:23 +0900 (JST)
Message-ID: <4FB1A115.2080303@jp.fujitsu.com>
Date: Tue, 15 May 2012 09:19:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 0/6] mm: memcg: statistics implementation cleanups
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/05/15 3:00), Johannes Weiner wrote:

> Before piling more things (reclaim stats) on top of the current mess,
> I thought it'd be better to clean up a bit.
> 
> The biggest change is printing statistics directly from live counters,
> it has always been annoying to declare a new counter in two separate
> enums and corresponding name string arrays.  After this series we are
> down to one of each.
> 
>  mm/memcontrol.c |  223 +++++++++++++++++------------------------------
>  1 file changed, 82 insertions(+), 141 deletions(-)
> 


to all 1-6. Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

One excuse for my old implementation of mem_cgroup_get_total_stat(),
which is fixed in patch 6, is that I thought it's better to touch all counters
in a cachineline at once and avoiding long distance for-each loop.

What number of performance difference with some big hierarchy(100+children) tree ?
(But I agree your code is cleaner. I'm just curious.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
