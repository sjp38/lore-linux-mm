Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA1A6B0011
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:36:27 -0400 (EDT)
Date: Fri, 13 May 2011 12:36:08 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 5/6] memcg: remove global LRU list
Message-ID: <20110513103608.GP16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-6-git-send-email-hannes@cmpxchg.org>
 <20110513095348.GE25304@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110513095348.GE25304@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 13, 2011 at 11:53:48AM +0200, Michal Hocko wrote:
> On Thu 12-05-11 16:53:57, Johannes Weiner wrote:
> > Since the VM now has means to do global reclaim from the per-memcg lru
> > lists, the global LRU list is no longer required.
> 
> Shouldn't this one be at the end of the series?

I don't really have an opinion.  Why do you think it should?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
