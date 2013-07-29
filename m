Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 69AC96B0033
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 14:26:39 -0400 (EDT)
Received: by mail-ye0-f177.google.com with SMTP id m4so1520778yen.8
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 11:26:38 -0700 (PDT)
Date: Mon, 29 Jul 2013 14:26:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/8] cgroup: document how cgroup IDs are assigned
Message-ID: <20130729182632.GC26076@mtj.dyndns.org>
References: <51F614B2.6010503@huawei.com>
 <51F614D4.6000703@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F614D4.6000703@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jul 29, 2013 at 03:08:04PM +0800, Li Zefan wrote:
> As cgroup id has been used in netprio cgroup and will be used in memcg,
> it's important to make it clear how a cgroup id is allocated.
> 
> For example, in netprio cgroup, the id is used as index of anarray.
> 
> Signed-off-by: Li Zefan <lizefan@huwei.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

We can merge this into the first patch?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
