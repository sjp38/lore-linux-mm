Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E63E26B0033
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:57:48 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id 4so686675pdd.31
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 08:57:48 -0700 (PDT)
Date: Mon, 22 Apr 2013 08:57:44 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422155744.GD12543@htj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422155703.GC12543@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

On Mon, Apr 22, 2013 at 08:57:03AM -0700, Tejun Heo wrote:
> On Mon, Apr 22, 2013 at 05:19:08PM +0200, Michal Hocko wrote:
> > We can try to be clever during the outside pressure and prefer
> > reclaiming over soft limit groups first. Which we used to do and will
> > do after rework as well. As a side effect of that a properly designed
> > hierachy with opt-in soft limited groups can actually accomplish some
> > isolation is a nice side effect but no _guarantee_.
> 
> Okay, so it *is* a soft limit.  Good.  If so, a subtree going over the
> limit of course forces reclaim on its children even though their
> individual configs aren't over limit.  It's exactly the same as
> hardlimit.  There doesn't need to be any difference and there's
> nothing questionable or interesting about it.
> 
> Also, then, a cgroup which has been configured explicitly shouldn't be
                                ^
				not

> disadvantaged compared to a cgroup with a limit configured.  ie. the
> current behavior of giving maximum to the knob on creation is the
> correct one.  The knob should create *extra* pressure.  It shouldn't
> lessen the pressure.  When populated weith other cgroups with limits
> configured, it would change the relative pressure felt by each but in
> general it's a limiting mechanism not an isolation one.  I think the
> bulk of confusion is coming from this, so please make that abundantly
> clear.
> 
> And, if people want a mechanism for isolation / lessening of pressure,
> which looks like a valid use case to me, add another knob for that
> which is prioritized under both hard and soft limits.  That is the
> only sensible way to do it.
> 
> Alright, no complaint anymore.  Thanks.
> 
> -- 
> tejun

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
