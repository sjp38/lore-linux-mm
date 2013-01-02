Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 108196B0071
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 10:34:42 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id x40so7273818qcp.26
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 07:34:42 -0800 (PST)
Date: Wed, 2 Jan 2013 10:34:39 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
Message-ID: <20130102153439.GA11220@mtj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <1354138460-19286-7-git-send-email-tj@kernel.org>
 <50DACF5B.6050705@huawei.com>
 <20121226120415.GA18193@mtj.dyndns.org>
 <87zk0s5h7c.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zk0s5h7c.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Li Zefan <lizefan@huawei.com>, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Rusty.

On Wed, Jan 02, 2013 at 03:12:15PM +1030, Rusty Russell wrote:
> > Hmmm?  cpumask_t can't be used for stack but other than that I don't
> > see how it would be deprecated completely.  Rusty, can you please
> > chime in?
> 
> The long-never-quite-complete-plan was for struct cpumask to be
> undefined when CONFIG_CPUMASK_OFFSTACK=y.  That means noone can declare
> them, or pass them on the stack, since they'll get a compiler error.
> 
> Now, there are some cases where it really is a reason to use a static
> bitmap, and 1/2 a K of wasted space be damned.  There's a
> deliberately-ugly way of doing that: declare a bitmap and use
> to_cpumask().  Of course, if we ever really want to remove NR_CPUS and
> make it completely generic, we have to kill all these too, but noone is
> serious about that.

So, I guess this currently is caught in a place which isn't here or
there.  I'm pretty skeptical whether it makes sense to bother about
static usages tho.  Can I keep them for static ones?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
