Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 5A6E76B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 08:58:49 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2201638pad.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 05:58:48 -0800 (PST)
Message-ID: <509BBA9C.7050007@gmail.com>
Date: Thu, 08 Nov 2012 21:58:52 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] oom: rework dump_tasks to optimize memcg-oom situation
References: <1352277602-21687-1-git-send-email-handai.szj@taobao.com> <1352277719-21760-1-git-send-email-handai.szj@taobao.com> <20121107223437.GC26382@dhcp22.suse.cz>
In-Reply-To: <20121107223437.GC26382@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 11/08/2012 06:34 AM, Michal Hocko wrote:
> On Wed 07-11-12 16:41:59, Sha Zhengju wrote:
>> From: Sha Zhengju<handai.szj@taobao.com>
>>
>> If memcg oom happening, don't scan all system tasks to dump memory state of
>> eligible tasks, instead we iterates only over the process attached to the oom
>> memcg and avoid the rcu lock.
> you have replaced rcu lock by css_set_lock which is, well, heavier than
> rcu. Besides that the patch is not correct because you have excluded
> all tasks that are from subgroups because you iterate only through the
> top level one.
> I am not sure the whole optimization would be a win even if implemented
> correctly. Well, we scan through more tasks currently and most of them
> are not relevant but then you would need to exclude task_in_mem_cgroup
> from oom_unkillable_task and that would be more code churn than the
> win.

Thanks for your and David's advice.
This piece is trying to save some expense while dumping memcg tasks, but 
failed to
scanning subgroups by iterating the cgroup. I'm agreed with your cost&win
opinion, so I decide to give up this one. : )


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
