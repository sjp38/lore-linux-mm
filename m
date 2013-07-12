Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 0D74D6B0033
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:48:41 -0400 (EDT)
Received: by mail-ye0-f169.google.com with SMTP id m1so3290671yen.28
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 11:48:41 -0700 (PDT)
Date: Fri, 12 Jul 2013 11:48:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] vmpressure: document why css_get/put is not
 necessary for work queue based signaling
Message-ID: <20130712184836.GC23680@mtj.dyndns.org>
References: <20130712084039.GA13224@dhcp22.suse.cz>
 <1373621098-15261-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373621098-15261-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Fri, Jul 12, 2013 at 11:24:56AM +0200, Michal Hocko wrote:
> Cgroup events are unregistered from the workqueue context by
> cgroup_event_remove scheduled by cgroup_destroy_locked (when a cgroup is
> removed by rmdir).
> 
> cgroup_event_remove removes the eventfd wait queue from the work
> queue, then it unregisters all the registered events and finally
> puts a reference to the cgroup dentry. css_free which triggers memcg
> deallocation is called after the last reference is dropped.
> 
> The scheduled vmpressure work item either happens before
> cgroup_event_remove or it is not triggered at all so it always happen
> _before_ the last dput thus css_free.

I don't follow what the above has to do with ensuring work item
execution is finished before the underlying data structure is
released.  How are the above relevant?  What am I missing here?

> This patch just documents this trickiness.

This doesn't have to be tricky at all.  It's a *completely* routine
thing.  Would you please stop making it one?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
