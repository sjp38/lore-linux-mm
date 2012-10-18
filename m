Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C99896B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 17:56:12 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so9890467pbb.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 14:56:12 -0700 (PDT)
Date: Thu, 18 Oct 2012 14:56:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/6] memcg: split mem_cgroup_force_empty into
 reclaiming and reparenting parts
Message-ID: <20121018215607.GN13370@google.com>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1350480648-10905-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, Oct 17, 2012 at 03:30:43PM +0200, Michal Hocko wrote:
> mem_cgroup_force_empty did two separate things depending on free_all
> parameter from the very beginning. It either reclaimed as many pages as
> possible and moved the rest to the parent or just moved charges to the
> parent. The first variant is used as memory.force_empty callback while
> the later is used from the mem_cgroup_pre_destroy.
> 
> The whole games around gotos are far from being nice and there is no
> reason to keep those two functions inside one. Let's split them and
> also move the responsibility for css reference counting to their callers
> to make to code easier.
> 
> This patch doesn't have any functional changes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
