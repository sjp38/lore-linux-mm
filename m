Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 8AB2A6B005D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:52:30 -0500 (EST)
Date: Tue, 4 Dec 2012 09:52:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] memcg: split part of memcg creation to css_online
Message-ID: <20121204085228.GD31319@dhcp22.suse.cz>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-4-git-send-email-glommer@parallels.com>
 <20121203173205.GI17093@dhcp22.suse.cz>
 <50BDAEC1.8040805@parallels.com>
 <20121204081756.GA31319@dhcp22.suse.cz>
 <50BDB511.5070107@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BDB511.5070107@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Tue 04-12-12 12:32:17, Glauber Costa wrote:
> On 12/04/2012 12:17 PM, Michal Hocko wrote:
> >> But it should be extremely easy to protect against this. It is just a
> >> > matter of not returning online css in the iterator: then we'll never see
> >> > them until they are online. This also sounds a lot more correct than
> >> > returning allocated css.
> > Yes but... Look at your other patch which relies on iterator when counting
> > children to find out if there is any available.
> >  
> And what is the problem with it ?

Bahh. Right you are because the value is copied only at the css_online
time.  So even if mem_cgroup_hierarchy_write wouldn't see any child
(because they are still offline) and managed to set use_hierarchy=1 with
some children linked in all would be fixed in mem_cgroup_css_online.

P.S.
Hey mhocko stop saying crap.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
