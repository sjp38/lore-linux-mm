Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9D5146B0109
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 11:36:41 -0400 (EDT)
Received: by mail-da0-f48.google.com with SMTP id p8so2652984dan.21
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 08:36:39 -0700 (PDT)
Date: Mon, 8 Apr 2013 08:36:35 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/12] cgroup: make sure parent won't be destroyed before
 its children
Message-ID: <20130408153635.GB3021@htj.dyndns.org>
References: <5162648B.9070802@huawei.com>
 <51626516.3000603@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51626516.3000603@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon, Apr 08, 2013 at 02:35:02PM +0800, Li Zefan wrote:
> Suppose we rmdir a cgroup and there're still css refs, this cgroup won't
> be freed. Then we rmdir the parent cgroup, and the parent is freed
> immediately due to css ref draining to 0. Now it would be a disaster if
> the still-alive child cgroup tries to access its parent.
> 
> Make sure this won't happen.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
