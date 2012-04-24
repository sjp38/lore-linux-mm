Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 5C55C6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 17:27:07 -0400 (EDT)
Date: Tue, 24 Apr 2012 23:26:33 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] Documentation: memcg: future proof hierarchical
 statistics documentation
Message-ID: <20120424212633.GK2536@cmpxchg.org>
References: <1335296038-29297-1-git-send-email-hannes@cmpxchg.org>
 <4F970826.8030702@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F970826.8030702@xenotime.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Apr 24, 2012 at 01:08:06PM -0700, Randy Dunlap wrote:
> On 04/24/2012 12:33 PM, Johannes Weiner wrote:
> 
> > The hierarchical versions of per-memcg counters in memory.stat are all
> > calculated the same way and are all named total_<counter>.
> > 
> > Documenting the pattern is easier for maintenance than listing each
> > counter twice.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Acked-by: Ying Han <yinghan@google.com>
> > ---
> >  Documentation/cgroups/memory.txt |   15 ++++-----------
> >  1 files changed, 4 insertions(+), 11 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index ab34ae5..6a066a2 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -432,17 +432,10 @@ hierarchical_memory_limit - # of bytes of memory limit with regard to hierarchy
> >  hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
> >  			hierarchy under which memory cgroup is.
> >  
> > -total_cache		- sum of all children's "cache"
> > -total_rss		- sum of all children's "rss"
> > -total_mapped_file	- sum of all children's "cache"
> > -total_pgpgin		- sum of all children's "pgpgin"
> > -total_pgpgout		- sum of all children's "pgpgout"
> > -total_swap		- sum of all children's "swap"
> > -total_inactive_anon	- sum of all children's "inactive_anon"
> > -total_active_anon	- sum of all children's "active_anon"
> > -total_inactive_file	- sum of all children's "inactive_file"
> > -total_active_file	- sum of all children's "active_file"
> > -total_unevictable	- sum of all children's "unevictable"
> > +total_<counter>		- # hierarchical version of <counter>, which in
> > +			addition to the cgroup's own value includes the
> > +			sum of all hierarchical children's values of
> > +			<counter>, i.e. total_cache
> 
> 			           e.g., total_cache
> 
> But how is a user or an admin supposed to know what all of the valid
> total_<counter> names are?  Is the entire list documented anywhere
> else other than here (which is being deleted)?

Yes, right above where the context of this patch ends is the original
list of counters, documenting cache, rss, mapped_file, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
