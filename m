Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 882C16B005D
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 17:20:45 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id 17so19119348iea.30
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 14:20:44 -0800 (PST)
Date: Thu, 3 Jan 2013 17:20:39 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20130103222039.GD2753@mtj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50DAD696.8050400@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50DAD696.8050400@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hey, Li.

On Wed, Dec 26, 2012 at 06:51:02PM +0800, Li Zefan wrote:
> I created a cpuset which has cpuset.cpus=1, and I forked a few cpu-hog tasks
> and moved them to this cpuset, and the final operations was offlining cpu1.
> It stucked.

This was caused by not rebuilding sched domains synchronously from cpu
offline path.  I looks like scheduler got confused and put tasks on
the dead cpu.  Should be okay in the updated patchset.  Can you please
test / review that one?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
