Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 6AA2A6B005A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:52:07 -0400 (EDT)
Date: Mon, 29 Oct 2012 14:52:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 2/6] memcg: root_cgroup cannot reach
 mem_cgroup_move_parent
Message-ID: <20121029135203.GA20757@dhcp22.suse.cz>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
 <1351251453-6140-3-git-send-email-mhocko@suse.cz>
 <508E8910.40203@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508E8910.40203@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Mon 29-10-12 17:48:00, Glauber Costa wrote:
> On 10/26/2012 03:37 PM, Michal Hocko wrote:
> > The root cgroup cannot be destroyed so we never hit it down the
> > mem_cgroup_pre_destroy path and mem_cgroup_force_empty_write shouldn't
> > even try to do anything if called for the root.
> > 
> > This means that mem_cgroup_move_parent doesn't have to bother with the
> > root cgroup and it can assume it can always move charges upwards.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Reviewed-by: Tejun Heo <tj@kernel.org>
> 
> I think it would be safer to have this folded in the last patch, to
> avoid a weird intermediate state (specially for force_empty).

force_empty excludes root cgroup explicitly so there is no way to fail
here. I have kept VM_BUG_ON for future reference but it also can go away
completely.

> Being a single statement, it doesn't confuse review so much.
> 
> However, this is also pretty much just a nitpick, do as you prefer.
> 
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
