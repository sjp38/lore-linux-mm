Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 93C3D6B005D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 18:42:41 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
In-Reply-To: <20130103022911.GH11220@mtj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org> <1354138460-19286-7-git-send-email-tj@kernel.org> <50DACF5B.6050705@huawei.com> <20121226120415.GA18193@mtj.dyndns.org> <87zk0s5h7c.fsf@rustcorp.com.au> <20130102153439.GA11220@mtj.dyndns.org> <871ue35bzk.fsf@rustcorp.com.au> <20130103022911.GH11220@mtj.dyndns.org>
Date: Mon, 07 Jan 2013 09:58:22 +1030
Message-ID: <87vcb951t5.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tejun Heo <tj@kernel.org> writes:

> Hello, Rusty.
>
> On Thu, Jan 03, 2013 at 11:17:11AM +1030, Rusty Russell wrote:
>> > So, I guess this currently is caught in a place which isn't here or
>> > there.  I'm pretty skeptical whether it makes sense to bother about
>> > static usages tho.  Can I keep them for static ones?
>> 
>> I didn't realize that cpuset_attach was a fastpath.  If it is, put a
>
> It isn't a hot path.  It's just a bit nasty to have to allocate them
> separately.
>
>> static there and I'll fix turn it into a bitmap when I need to.
>> Otherwise, please don't change the code in the first place.
>
> So, the plan to drop cpumask_t is still on?  If so, I'll leave
> cpumask_var_t.

Yep!

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
