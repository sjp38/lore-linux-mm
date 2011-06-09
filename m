Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EC3536B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 09:46:30 -0400 (EDT)
Date: Thu, 9 Jun 2011 15:45:59 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110609134559.GB14826@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <20110609131203.GB3994@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110609131203.GB3994@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 09, 2011 at 03:12:03PM +0200, Michal Hocko wrote:
> On Wed 01-06-11 08:25:13, Johannes Weiner wrote:
> [...]
> 
> Just a minor thing. I am really slow at reviewing these days due to
> other work that has to be done...
> 
> > +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> > +					     struct mem_cgroup *prev)
> > +{
> > +	struct mem_cgroup *mem;
> 
> You want mem = NULL here because you might end up using it unitialized
> AFAICS (css_get_next returns with NULL).

Thanks for pointing it out.  It was introduced when I switched from
using @prev to continue the search to using root->last_scanned_child.

It's fixed now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
