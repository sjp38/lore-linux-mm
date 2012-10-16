Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1F4996B0085
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 06:41:36 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so3638761dad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 03:41:35 -0700 (PDT)
Message-ID: <507D39E5.5010301@gmail.com>
Date: Tue, 16 Oct 2012 18:41:41 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
References: <1350382328-28977-1-git-send-email-handai.szj@taobao.com> <507D34E3.3040705@gmail.com>
In-Reply-To: <507D34E3.3040705@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 10/16/2012 06:20 PM, Ni zhan Chen wrote:
> On 10/16/2012 06:12 PM, Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Sysctl oom_kill_allocating_task enables or disables killing the 
>> OOM-triggering
>> task in out-of-memory situations, but it only works on overall 
>> system-wide oom.
>> But it's also a useful indication in memcg so we take it into 
>> consideration
>> while oom happening in memcg. Other sysctl such as panic_on_oom has 
>> already
>> been memcg-ware.
>
> Is it the resend one or new version, could you add changelog if it is 
> the last case?

Sorry, forget to mention that this patch is an updated one rebased on 
mhocko mm tree, since-3.6 branch.
The first one is on old kernel, please ignore it. :-)


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
