Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C0E166B0024
	for <linux-mm@kvack.org>; Mon, 16 May 2011 06:35:50 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4GAZktf029633
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:05:46 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GAZkFU2388122
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:05:46 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GAZjrx002094
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:05:45 +0530
Date: Mon, 16 May 2011 16:00:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [rfc patch 0/6] mm: memcg naturalization
Message-ID: <20110516103034.GI22412@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Johannes Weiner <hannes@cmpxchg.org> [2011-05-12 16:53:52]:

> Hi!
> 
> Here is a patch series that is a result of the memcg discussions on
> LSF (memcg-aware global reclaim, global lru removal, struct
> page_cgroup reduction, soft limit implementation) and the recent
> feature discussions on linux-mm.
> 
> The long-term idea is to have memcgs no longer bolted to the side of
> the mm code, but integrate it as much as possible such that there is a
> native understanding of containers, and that the traditional !memcg
> setup is just a singular group.  This series is an approach in that
> direction.
> 
> It is a rather early snapshot, WIP, barely tested etc., but I wanted
> to get your opinions before further pursuing it.  It is also part of
> my counter-argument to the proposals of adding memcg-reclaim-related
> user interfaces at this point in time, so I wanted to push this out
> the door before things are merged into .40.
> 
> The patches are quite big, I am still looking for things to factor and
> split out, sorry for this.  Documentation is on its way as well ;)
> 
> #1 and #2 are boring preparational work.  #3 makes traditional reclaim
> in vmscan.c memcg-aware, which is a prerequisite for both removal of
> the global lru in #5 and the way I reimplemented soft limit reclaim in
> #6.

A large part of the acceptance would be based on what the test results
for common mm benchmarks show.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
