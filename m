Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6736B0011
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:29:19 -0400 (EDT)
Date: Fri, 13 May 2011 12:28:58 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 3/6] mm: memcg-aware global reclaim
Message-ID: <20110513102858.GO16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
 <20110513095308.GD25304@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110513095308.GD25304@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 13, 2011 at 11:53:08AM +0200, Michal Hocko wrote:
> On Thu 12-05-11 16:53:55, Johannes Weiner wrote:
> > A page charged to a memcg is linked to a lru list specific to that
> > memcg.  At the same time, traditional global reclaim is obvlivious to
> > memcgs, and all the pages are also linked to a global per-zone list.
> > 
> > This patch changes traditional global reclaim to iterate over all
> > existing memcgs, so that it no longer relies on the global list being
> > present.
> 
> At LSF we have discussed that we should keep a list of over-(soft)limit
> cgroups in a list which would be the first target for reclaiming (in
> round-robin fashion). If we are note able to reclaim enough from those
> (the list becomes empty) we should fallback to the all groups reclaim
> (what you did in this patchset).

This would be on top or instead of 6/6.  This, 3/6, is indepent of
soft limit reclaim.  It is mainly in preparation to remove the global
LRU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
