Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 366156B0068
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 07:04:20 -0500 (EST)
Received: by mail-vb0-f54.google.com with SMTP id l1so8760551vba.27
        for <linux-mm@kvack.org>; Wed, 26 Dec 2012 04:04:19 -0800 (PST)
Date: Wed, 26 Dec 2012 07:04:15 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
Message-ID: <20121226120415.GA18193@mtj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <1354138460-19286-7-git-send-email-tj@kernel.org>
 <50DACF5B.6050705@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50DACF5B.6050705@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>

(cc'ing Rusty, hi!)

Hello, Li.

On Wed, Dec 26, 2012 at 06:20:11PM +0800, Li Zefan wrote:
> On 2012/11/29 5:34, Tejun Heo wrote:
> > cpuset_can_attach() prepare global variables cpus_attach and
> > cpuset_attach_nodemask_{to|from} which are used by cpuset_attach().
> > There is no reason to prepare in cpuset_can_attach().  The same
> > information can be accessed from cpuset_attach().
> > 
> > Move the prepartion logic from cpuset_can_attach() to cpuset_attach()
> > and make the global variables static ones inside cpuset_attach().
> > 
> > While at it, convert cpus_attach to cpumask_t from cpumask_var_t.
> > There's no reason to mess with dynamic allocation on a static buffer.
> > 
> 
> But Rusty had been deprecating the use of cpumask_t. I don't know why
> the final deprecation hasn't been completed yet.

Hmmm?  cpumask_t can't be used for stack but other than that I don't
see how it would be deprecated completely.  Rusty, can you please
chime in?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
