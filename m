Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 412F36B00FA
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:37:08 -0400 (EDT)
Date: Mon, 8 Apr 2013 16:37:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/8] memcg, cgroup: kill css_id
Message-ID: <20130408143704.GJ17178@dhcp22.suse.cz>
References: <51627DA9.7020507@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627DA9.7020507@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon 08-04-13 16:19:53, Li Zefan wrote:
[...]
>  include/linux/cgroup.h |  44 ++-------
>  kernel/cgroup.c        | 302 +++++++++-----------------------------------------------------
>  mm/memcontrol.c        |  53 ++++++-----
>  3 files changed, 77 insertions(+), 322 deletions(-)

Nice and thanks a lot Li!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
