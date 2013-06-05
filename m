Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 7668A6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 10:50:33 -0400 (EDT)
Date: Wed, 5 Jun 2013 10:50:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605145021.GR15576@cmpxchg.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605143949.GQ15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed, Jun 05, 2013 at 10:39:49AM -0400, Johannes Weiner wrote:
> On Wed, Jun 05, 2013 at 01:20:23AM -0700, Tejun Heo wrote:
> > Hello, Michal.
> > 
> > On Wed, Jun 05, 2013 at 09:30:23AM +0200, Michal Hocko wrote:
> > > > We aren't talking about something gigantic or can
> > > 
> > > mem_cgroup is 888B now (depending on configuration). So I wouldn't call
> > > it negligible.
> > 
> > Do you think that the number can actually grow harmful?  Would you be
> > kind enough to share some calculations with me?
> 
> 5k cgroups * say 10 priority levels * 1k struct mem_cgroup may pin 51M
> of dead struct mem_cgroup, plus whatever else the css pins.

Bleh, ... * nr_node_ids * MAX_NR_ZONES.  So it is a couple hundred MB
in that case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
