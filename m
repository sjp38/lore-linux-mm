Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 4ACF56B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:30:55 -0400 (EDT)
Date: Thu, 4 Apr 2013 17:30:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 5/7] cgroup: make sure parent won't be destroyed
 before its children
Message-ID: <20130404153051.GL29911@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
 <515BF2A4.1070703@huawei.com>
 <20130404113750.GH29911@dhcp22.suse.cz>
 <20130404133706.GA9425@htj.dyndns.org>
 <20130404152028.GK29911@dhcp22.suse.cz>
 <20130404152213.GL9425@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130404152213.GL9425@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 04-04-13 08:22:13, Tejun Heo wrote:
> On Thu, Apr 04, 2013 at 05:20:28PM +0200, Michal Hocko wrote:
> > > But what harm does an additional reference do?
> > 
> > No harm at all. I just wanted to be sure that this is not yet another
> > "for memcg" hack. So if this is useful for other controllers then I have
> > no objections of course.
> 
> I think it makes sense in general, so let's do it in cgroup core.

Ok

> I suppose it'd be easier for this to be routed together with other
> memcg changes?

Probably yes.

> Thanks.
> 
> -- 
> tejun
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
