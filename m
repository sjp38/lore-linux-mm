Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 17D4D6B005A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:48:11 -0400 (EDT)
Message-ID: <508E8910.40203@parallels.com>
Date: Mon, 29 Oct 2012 17:48:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/6] memcg: root_cgroup cannot reach mem_cgroup_move_parent
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz> <1351251453-6140-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1351251453-6140-3-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On 10/26/2012 03:37 PM, Michal Hocko wrote:
> The root cgroup cannot be destroyed so we never hit it down the
> mem_cgroup_pre_destroy path and mem_cgroup_force_empty_write shouldn't
> even try to do anything if called for the root.
> 
> This means that mem_cgroup_move_parent doesn't have to bother with the
> root cgroup and it can assume it can always move charges upwards.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: Tejun Heo <tj@kernel.org>

I think it would be safer to have this folded in the last patch, to
avoid a weird intermediate state (specially for force_empty). Being a
single statement, it doesn't confuse review so much.

However, this is also pretty much just a nitpick, do as you prefer.

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
