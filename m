Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 52AC3900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:01:29 -0400 (EDT)
Date: Fri, 13 May 2011 13:01:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [rfc patch 5/6] memcg: remove global LRU list
Message-ID: <20110513110124.GF25304@tiehlicka.suse.cz>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-6-git-send-email-hannes@cmpxchg.org>
 <20110513095348.GE25304@tiehlicka.suse.cz>
 <20110513103608.GP16531@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110513103608.GP16531@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-05-11 12:36:08, Johannes Weiner wrote:
> On Fri, May 13, 2011 at 11:53:48AM +0200, Michal Hocko wrote:
> > On Thu 12-05-11 16:53:57, Johannes Weiner wrote:
> > > Since the VM now has means to do global reclaim from the per-memcg lru
> > > lists, the global LRU list is no longer required.
> > 
> > Shouldn't this one be at the end of the series?
> 
> I don't really have an opinion.  Why do you think it should?

It is the last step in my eyes and maybe we want to keep both global
LRU as a fallback for some time just to get an impression (with some
tracepoints)how well does the per-cgroup reclaim goes.

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
