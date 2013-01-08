Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E442B6B005A
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 20:32:40 -0500 (EST)
Message-ID: <50EB76DF.5070508@huawei.com>
Date: Tue, 8 Jan 2013 09:31:11 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET] cpuset: decouple cpuset locking from cgroup core,
 take#2
References: <1357248967-24959-1-git-send-email-tj@kernel.org> <50E93554.3070102@huawei.com> <20130107164453.GH3926@htj.dyndns.org>
In-Reply-To: <20130107164453.GH3926@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/1/8 0:44, Tejun Heo wrote:
> Hello, Li.
> 
> On Sun, Jan 06, 2013 at 04:27:00PM +0800, Li Zefan wrote:
>> I've reviewed and tested the patchset, and it looks good to me!
>>
>> Acked-by: Li Zefan <lizefan@huawei.com>
> 
> Great.  Ummm... How should we route this?  Paul doesn't seem to be
> looking at this.  I can route it through cgroup tree.  Any objections?
> 

I don't think Paul's still maintaining cpusets. Normally it's Andrew
that picks up cpuset patches. It's fine you route it through cgroup
tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
