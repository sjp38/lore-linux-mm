Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id EDF226B0068
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 18:48:11 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so9884456pad.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 15:48:11 -0700 (PDT)
Date: Thu, 18 Oct 2012 15:48:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 5/6] memcg: make mem_cgroup_reparent_charges non failing
Message-ID: <20121018224807.GT13370@google.com>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-6-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1350480648-10905-6-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, Oct 17, 2012 at 03:30:47PM +0200, Michal Hocko wrote:
> Now that pre_destroy callbacks are called from within cgroup_lock and
> the cgroup has been checked to be empty without any children then there
> is no other way to fail.
> mem_cgroup_pre_destroy doesn't have to take a reference to memcg's css
> because all css' are marked dead already.
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
