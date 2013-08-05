Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id E968E6B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 12:01:10 -0400 (EDT)
Date: Mon, 5 Aug 2013 18:01:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: make cgroup_event specific to
 memcg
Message-ID: <20130805160107.GM10146@dhcp22.suse.cz>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375632446-2581-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 04-08-13 12:07:21, Tejun Heo wrote:
> Hello,

Hi Tejun,

> Like many other things in cgroup, cgroup_event is way too flexible and
> complex - it strives to provide completely flexible event monitoring
> facility in cgroup proper which allows any number of users to monitor
> custom events.  This is overboard, to say the least,

Could you be more specific about what is so "overboard" about this
interface? I am not familiar with internals much, so I cannot judge the
complexity part, but I thought that eventfd was intended for this kind
of kernel->userspace notifications.

> and I strongly think that cgroup should not any new usages of this
> facility and preferably deprecate the existing usages if at all
> possible.

So you think that vmpressure, oom notification or thresholds are
an abuse of this interface? What would you consider a reasonable
replacement for those notifications?  Or do you think that controller
shouldn't be signaling any conditions to the userspace at all?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
