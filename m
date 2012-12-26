Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 32D3B6B0044
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 05:22:03 -0500 (EST)
Message-ID: <50DACF5B.6050705@huawei.com>
Date: Wed, 26 Dec 2012 18:20:11 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
References: <1354138460-19286-1-git-send-email-tj@kernel.org> <1354138460-19286-7-git-send-email-tj@kernel.org>
In-Reply-To: <1354138460-19286-7-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012/11/29 5:34, Tejun Heo wrote:
> cpuset_can_attach() prepare global variables cpus_attach and
> cpuset_attach_nodemask_{to|from} which are used by cpuset_attach().
> There is no reason to prepare in cpuset_can_attach().  The same
> information can be accessed from cpuset_attach().
> 
> Move the prepartion logic from cpuset_can_attach() to cpuset_attach()
> and make the global variables static ones inside cpuset_attach().
> 
> While at it, convert cpus_attach to cpumask_t from cpumask_var_t.
> There's no reason to mess with dynamic allocation on a static buffer.
> 

But Rusty had been deprecating the use of cpumask_t. I don't know why
the final deprecation hasn't been completed yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
