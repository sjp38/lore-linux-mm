Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0A3CF6B005D
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 22:43:26 -0500 (EST)
Message-ID: <50E64FB0.9050803@huawei.com>
Date: Fri, 4 Jan 2013 11:42:40 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 7/7] cgroup: remove css_get_next
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz> <1357235661-29564-8-git-send-email-mhocko@suse.cz>
In-Reply-To: <1357235661-29564-8-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

On 2013/1/4 1:54, Michal Hocko wrote:
> Now that we have generic and well ordered cgroup tree walkers there is
> no need to keep css_get_next in the place.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Li Zefan <lizefan@huawei.com>

> ---
>  include/linux/cgroup.h |    7 -------
>  kernel/cgroup.c        |   49 ------------------------------------------------
>  2 files changed, 56 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
