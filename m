Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id DF38E6B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 10:08:53 -0400 (EDT)
Message-ID: <508E8DEB.3000302@parallels.com>
Date: Mon, 29 Oct 2012 18:08:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 6/6] hugetlb: do not fail in hugetlb_cgroup_pre_destroy
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz> <1351251453-6140-7-git-send-email-mhocko@suse.cz>
In-Reply-To: <1351251453-6140-7-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On 10/26/2012 03:37 PM, Michal Hocko wrote:
> Now that pre_destroy callbacks are called from the context where neither
> any task can attach the group nor any children group can be added there
> is no other way to fail from hugetlb_pre_destroy.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: Tejun Heo <tj@kernel.org>

Same as Patch5:
Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
