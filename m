Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2F8866B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:07:03 -0500 (EST)
Message-ID: <50EFD5C3.7020406@huawei.com>
Date: Fri, 11 Jan 2013 17:05:07 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET] cpuset: decouple cpuset locking from cgroup core,
 take#2
References: <1357248967-24959-1-git-send-email-tj@kernel.org> <50E93554.3070102@huawei.com> <20130107164453.GH3926@htj.dyndns.org> <50EB76DF.5070508@huawei.com> <20130109185724.GP3926@htj.dyndns.org>
In-Reply-To: <20130109185724.GP3926@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/1/10 2:57, Tejun Heo wrote:
> Hello, Li.
> 
> On Tue, Jan 08, 2013 at 09:31:11AM +0800, Li Zefan wrote:
>> I don't think Paul's still maintaining cpusets. Normally it's Andrew
>> that picks up cpuset patches. It's fine you route it through cgroup
>> tree.
> 
> Can you please take over the cpuset maintainership then?  I think you
> would be the one most familiar with the code base at this point.
> 

Sure, I'll send a patch to update MAINTAINERS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
