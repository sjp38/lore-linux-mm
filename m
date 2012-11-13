Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B1F596B0070
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 16:13:29 -0500 (EST)
Date: Tue, 13 Nov 2012 16:13:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 4/6] cgroups: forbid pre_destroy callback to fail
Message-ID: <20121113211324.GC1543@cmpxchg.org>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
 <1351251453-6140-5-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351251453-6140-5-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@parallels.com>

On Fri, Oct 26, 2012 at 01:37:31PM +0200, Michal Hocko wrote:
> Now that mem_cgroup_pre_destroy callback doesn't fail (other than a race
> with a task attach resp. child group appears) finally we can safely move
> on and forbit all the callbacks to fail.
> The last missing piece is moving cgroup_call_pre_destroy after
> cgroup_clear_css_refs so that css_tryget fails so no new charges for the
> memcg can happen.
> We cannot, however, move cgroup_call_pre_destroy right after because we
> cannot call mem_cgroup_pre_destroy with the cgroup_lock held (see
> 3fa59dfb cgroup: fix potential deadlock in pre_destroy) so we have to
> move it after the lock is released.
> 
> Changes since v1
> - Li Zefan pointed out that mem_cgroup_pre_destroy cannot be called with
>   cgroup_lock held
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
