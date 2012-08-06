Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 6BEFD6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 09:26:58 -0400 (EDT)
Date: Mon, 6 Aug 2012 15:26:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V8 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
Message-ID: <20120806132655.GB6150@dhcp22.suse.cz>
References: <1343942664-13365-1-git-send-email-yinghan@google.com>
 <20120803140224.GC8434@dhcp22.suse.cz>
 <501BF98B.9030103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <501BF98B.9030103@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri 03-08-12 12:17:15, Rik van Riel wrote:
> On 08/03/2012 10:02 AM, Michal Hocko wrote:
> >On Thu 02-08-12 14:24:24, Ying Han wrote:
> 		shrink_lruvec(lruvec, sc);
> >>
> >>+			if (!mem_cgroup_is_root(memcg))
> >>+				over_softlimit = true;
> >>+		}
> >>+
> >
> >I think this is still not sufficient because you do not want to hammer
> >root in the ignore_softlimit case.
> 
> Michal, please see my mail from a few days ago, describing how I
> plan to balance pressure between the various LRU lists.

I have noticed your email but didn't get to the details yet.

> I hope to throw a prototype patch over the wall soon...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
