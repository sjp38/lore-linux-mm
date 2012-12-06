Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 183BA6B005D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 01:26:14 -0500 (EST)
Message-ID: <50C03A3F.7070605@huawei.com>
Date: Thu, 6 Dec 2012 14:25:03 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
References: <1354138460-19286-1-git-send-email-tj@kernel.org> <20121203152205.GB17093@dhcp22.suse.cz> <20121203165338.GF19802@htj.dyndns.org>
In-Reply-To: <20121203165338.GF19802@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012/12/4 0:53, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Dec 03, 2012 at 04:22:05PM +0100, Michal Hocko wrote:
>> I have glanced through the series and spotten nothing obviously wrong. I
>> do not feel I could give my r-b because I am not familiar with cpusets
>> internals enough and some patches looks quite scary (like #8).
>> Anyway the resulting outcome seems nice.
> 
> Thanks a lot for looking at it and, yeah, it's a bit scary.  Li, Paul,
> can you guys please review the series?
> 

We shoudn't haste to target this for 3.8, given that we're in late -rc and
Michal felt some patches scary and they hasn't got enough review.

I'll squeeze time to review them, but currently I've been backlogged with
internal work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
