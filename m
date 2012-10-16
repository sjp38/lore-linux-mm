Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 6DD7E6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 02:32:00 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so3510203dad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 23:31:59 -0700 (PDT)
Message-ID: <507CFF65.7050109@gmail.com>
Date: Tue, 16 Oct 2012 14:32:05 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
References: <1350367837-27919-1-git-send-email-handai.szj@taobao.com> <alpine.DEB.2.00.1210152311460.9480@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210152311460.9480@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sha Zhengju <handai.szj@taobao.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org

On 10/16/2012 02:12 PM, David Rientjes wrote:
> On Tue, 16 Oct 2012, Sha Zhengju wrote:
>
>> From: Sha Zhengju<handai.szj@taobao.com>
>>
>> Sysctl oom_kill_allocating_task enables or disables killing the OOM-triggering
>> task in out-of-memory situations, but it only works on overall system-wide oom.
>> But it's also a useful indication in memcg so we take it into consideration
>> while oom happening in memcg. Other sysctl such as panic_on_oom has already
>> been memcg-ware.
>>
> You're working on an old kernel, mem_cgroup_out_of_memory() has moved to
> mm/memcontrol.c.  Please rebase on 3.7-rc1 and send an updated patch,
> which otherwise looks good.

Thanks for reminding!  Yes, I cooked it on memcg-devel git repo but a 
out-of-date
since-3.2 branch... But I notice the latest branch is since-3.5(not 
seeing 3.6/3.7), does
it okay to working on this branch?


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
