Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3471C6B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 17:58:12 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so4302020dad.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 14:58:11 -0700 (PDT)
Date: Thu, 18 Oct 2012 14:58:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/6] memcg: root_cgroup cannot reach
 mem_cgroup_move_parent
Message-ID: <20121018215807.GO13370@google.com>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1350480648-10905-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, Oct 17, 2012 at 03:30:44PM +0200, Michal Hocko wrote:
> The root cgroup cannot be destroyed so we never hit it idown the
> mem_cgroup_pre_destroy path and mem_cgroup_force_empty_write shouldn't
> even try to do anything if called for the root.
> 
> This means that mem_cgroup_move_parent doesn't have to bother with the
> root cgroup and it can assume it can always move charges upwards.
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
