Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 94E786B006C
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 13:57:29 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz11so1209275pad.31
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 10:57:28 -0800 (PST)
Date: Wed, 9 Jan 2013 10:57:24 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] cpuset: decouple cpuset locking from cgroup core,
 take#2
Message-ID: <20130109185724.GP3926@htj.dyndns.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
 <50E93554.3070102@huawei.com>
 <20130107164453.GH3926@htj.dyndns.org>
 <50EB76DF.5070508@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50EB76DF.5070508@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Li.

On Tue, Jan 08, 2013 at 09:31:11AM +0800, Li Zefan wrote:
> I don't think Paul's still maintaining cpusets. Normally it's Andrew
> that picks up cpuset patches. It's fine you route it through cgroup
> tree.

Can you please take over the cpuset maintainership then?  I think you
would be the one most familiar with the code base at this point.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
