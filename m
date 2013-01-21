Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 4999A6B0009
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:42:17 -0500 (EST)
Message-ID: <50FCFF76.6090202@parallels.com>
Date: Mon, 21 Jan 2013 12:42:30 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/7] memcg: split part of memcg creation to css_online
References: <1357897527-15479-1-git-send-email-glommer@parallels.com> <1357897527-15479-3-git-send-email-glommer@parallels.com> <20130118152526.GF10701@dhcp22.suse.cz> <50FCEF40.8040709@parallels.com> <20130121083828.GB7798@dhcp22.suse.cz>
In-Reply-To: <20130121083828.GB7798@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 01/21/2013 12:38 PM, Michal Hocko wrote:
> On Mon 21-01-13 11:33:20, Glauber Costa wrote:
>> On 01/18/2013 07:25 PM, Michal Hocko wrote:
>>>> -	spin_lock_init(&memcg->move_lock);
>>>>> +	memcg->swappiness = mem_cgroup_swappiness(parent);
>>> Please move this up to oom_kill_disable and use_hierarchy
>>> initialization.
>>
>> One thing: wouldn't moving it to inside use_hierarchy be a change of
>> behavior here?
> 
> I do not see how it would change the behavior. But maybe I wasn't clear
> enough. I just wanted to make all three:
> 	memcg->use_hierarchy = parent->use_hierarchy;
> 	memcg->oom_kill_disable = parent->oom_kill_disable;
> 	memcg->swappiness = mem_cgroup_swappiness(parent);
> 
> in the same visual block so that we can split the function into three
> parts. Inherited values which don't depend on use_hierarchy, those that
> depend on use_hierarchy and the rest that depends on the previous
> decisions (kmem e.g.).
> Makes sense?
> 
Yes. I misunderstood you, believing you wanted the swappiness assignment
to go inside the use_hierarchy block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
