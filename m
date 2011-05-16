Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1636B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 06:58:03 -0400 (EDT)
Date: Mon, 16 May 2011 12:57:29 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 0/6] mm: memcg naturalization
Message-ID: <20110516105729.GR16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <20110516103034.GI22412@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110516103034.GI22412@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 16, 2011 at 04:00:34PM +0530, Balbir Singh wrote:
> * Johannes Weiner <hannes@cmpxchg.org> [2011-05-12 16:53:52]:
> 
> > Hi!
> > 
> > Here is a patch series that is a result of the memcg discussions on
> > LSF (memcg-aware global reclaim, global lru removal, struct
> > page_cgroup reduction, soft limit implementation) and the recent
> > feature discussions on linux-mm.
> > 
> > The long-term idea is to have memcgs no longer bolted to the side of
> > the mm code, but integrate it as much as possible such that there is a
> > native understanding of containers, and that the traditional !memcg
> > setup is just a singular group.  This series is an approach in that
> > direction.
> > 
> > It is a rather early snapshot, WIP, barely tested etc., but I wanted
> > to get your opinions before further pursuing it.  It is also part of
> > my counter-argument to the proposals of adding memcg-reclaim-related
> > user interfaces at this point in time, so I wanted to push this out
> > the door before things are merged into .40.
> > 
> > The patches are quite big, I am still looking for things to factor and
> > split out, sorry for this.  Documentation is on its way as well ;)
> > 
> > #1 and #2 are boring preparational work.  #3 makes traditional reclaim
> > in vmscan.c memcg-aware, which is a prerequisite for both removal of
> > the global lru in #5 and the way I reimplemented soft limit reclaim in
> > #6.
> 
> A large part of the acceptance would be based on what the test results
> for common mm benchmarks show.

I will try to ensure the following things:

1. will not degrade performance on !CONFIG_MEMCG kernels

2. will not degrade performance on CONFIG_MEMCG kernels without
configured memcgs.  This might be the most important one as most
desktop/server distributions enable the memory controller per default

3. will not degrade overall performance of workloads running
concurrently in separate memory control groups.  I expect some shifts,
however, that even out performance differences.

Please let me know what you consider common mm benchmarks.

Thanks!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
