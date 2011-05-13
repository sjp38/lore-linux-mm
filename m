Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA9C90010B
	for <linux-mm@kvack.org>; Fri, 13 May 2011 05:53:12 -0400 (EDT)
Date: Fri, 13 May 2011 11:53:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [rfc patch 3/6] mm: memcg-aware global reclaim
Message-ID: <20110513095308.GD25304@tiehlicka.suse.cz>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 12-05-11 16:53:55, Johannes Weiner wrote:
> A page charged to a memcg is linked to a lru list specific to that
> memcg.  At the same time, traditional global reclaim is obvlivious to
> memcgs, and all the pages are also linked to a global per-zone list.
> 
> This patch changes traditional global reclaim to iterate over all
> existing memcgs, so that it no longer relies on the global list being
> present.

At LSF we have discussed that we should keep a list of over-(soft)limit
cgroups in a list which would be the first target for reclaiming (in
round-robin fashion). If we are note able to reclaim enough from those
(the list becomes empty) we should fallback to the all groups reclaim
(what you did in this patchset).

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
