Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id D32816B0275
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 11:25:33 -0500 (EST)
Date: Tue, 13 Dec 2011 17:25:31 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: Use gfp_mask __GFP_NORETRY in try charge
Message-ID: <20111213162531.GF30440@tiehlicka.suse.cz>
References: <1323742587-9084-1-git-send-email-yinghan@google.com>
 <20111213162126.GE30440@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111213162126.GE30440@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Tue 13-12-11 17:21:26, Michal Hocko wrote:
> On Mon 12-12-11 18:16:27, Ying Han wrote:
> > In __mem_cgroup_try_charge() function, the parameter "oom" is passed from the
> > caller indicating whether or not the charge should enter memcg oom kill. In
> > fact, we should be able to eliminate that by using the existing gfp_mask and
> > __GFP_NORETRY flag.
> > 
> > This patch removed the "oom" parameter, and add the __GFP_NORETRY flag into
> > gfp_mask for those doesn't want to enter memcg oom. There is no functional
> > change for those setting false to "oom" like mem_cgroup_move_parent(), but
> > __GFP_NORETRY now is checked for those even setting true to "oom".
> > 
> > The __GFP_NORETRY is used in page allocator to bypass retry and oom kill. I
> > believe there is a reason for callers to use that flag, and in memcg charge
> > we need to respect it as well.
> 
> What is the reason for this change?

Ahh, just noticed the second patch. Give me some time to think about
that.
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
