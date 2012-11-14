Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E5BFA6B006C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 03:37:03 -0500 (EST)
Date: Wed, 14 Nov 2012 09:36:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] rework mem_cgroup iterator
Message-ID: <20121114083653.GA17111@dhcp22.suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <50A2F9FC.5050303@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A2F9FC.5050303@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

On Wed 14-11-12 09:55:08, Li Zefan wrote:
> On 2012/11/13 23:30, Michal Hocko wrote:
> > Hi all,
> > this patch set tries to make mem_cgroup_iter saner in the way how it
> > walks hierarchies. css->id based traversal is far from being ideal as it
> > is not deterministic because it depends on the creation ordering.
> > 
> > Diffstat looks promising but it is fair the say that the biggest cleanup is
> > just css_get_next removal. The memcg code has grown a bit but I think it is
> > worth the resulting outcome (the sanity ;)).
> > 
> 
> So memcg won't use css id at all, right?

Unfortunately we still use it for the swap accounting but that one could
be replaced by something else, probably. Have to think about it.

> Then we can remove the whole css_id stuff, and that's quite a bunch of
> code.

Is memcg the only user of css_id? Quick grep shows that yes but I
haven't checked all the callers of the exported functions. I would be
happy if more code goes away.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
