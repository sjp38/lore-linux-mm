Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DB85D6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:24:48 -0400 (EDT)
Message-ID: <4FE9FDCC.80000@parallels.com>
Date: Tue, 26 Jun 2012 22:22:04 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
References: <1340717428-9009-1-git-send-email-glommer@parallels.com> <20120626181209.GR3869@google.com>
In-Reply-To: <20120626181209.GR3869@google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 06/26/2012 10:12 PM, Tejun Heo wrote:
> On Tue, Jun 26, 2012 at 05:30:28PM +0400, Glauber Costa wrote:
>> Okay, so after recent discussions, I am proposing the following
>> patch. It won't remove hierarchy, or anything like that. Just default
>> to true in the root cgroup, and print a warning once if you try
>> to set it back to 0.
>>
>> I am not adding it to feature-removal-schedule.txt because I don't
>> view it as a consensus. Rather, changing the default would allow us
>> to give it a time around in the open, and see if people complain
>> and what we can learn about that.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Tejun Heo <tj@kernel.org>
>
> Just in case it wasn't clear in the other posting.
>
>   Nacked-by: Tejun Heo <tj@kernel.org>
>
> You can't change the default behavior silently.  Not in this scale.
>
> Thanks.
>
I certainly don't share your views of the matter here.

I would agree with you if we were changing a fundamental algorithm,
with no way to resort back to a default setup. We are not removing any
functionality whatsoever here.

I would agree with you if we were actually documenting explicitly
that this is an expected default behavior.

But we never made the claim that use_hierarchy would default to 0.

Well, we seldom make claims about default values of any tunables. We 
just expect them to be reasonable values, and we seem to agree that this 
is, indeed, reasonable.

I personally consider this even better than a mount option. It doesn't 
add or remove any new interface, since use_hierarchy was already there.

It doesn't change the behavior of any interface. What would happen for 
instance if I rely on a multitude of use_hierarchy = 0 and 1 and 
suddenly a mount option would override that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
