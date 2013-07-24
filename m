Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B9FA56B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:14:12 -0400 (EDT)
Received: by mail-ye0-f177.google.com with SMTP id m4so1414379yen.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:14:11 -0700 (PDT)
Date: Wed, 24 Jul 2013 12:14:07 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 0/8] memcg, cgroup: kill css_id
Message-ID: <20130724161407.GD20377@mtj.dyndns.org>
References: <51EFA554.6080801@huawei.com>
 <20130724143214.GL2540@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130724143214.GL2540@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed, Jul 24, 2013 at 04:32:14PM +0200, Michal Hocko wrote:
> On Wed 24-07-13 17:58:44, Li Zefan wrote:
> > This patchset converts memcg to use cgroup->id, and then we can remove
> > cgroup css_id.
> > 
> > As we've removed memcg's own refcnt, converting memcg to use cgroup->id
> > is very straight-forward.
> > 
> > The patchset is based on Tejun's cgroup tree.
> 
> Does it depend on any particular patches? I am asking because I would
> need to cherry pick those and apply them into my -mm git tree before
> these.

I'll set up a branch with the prep cgroup patches bsaed on top of
v3.10 which you can pull into your tree (let's please not cherry-pick)
and the memcg part and actual css_id removal can be carried through
-mm.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
