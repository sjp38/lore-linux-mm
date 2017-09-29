Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC796B025F
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 02:48:58 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h9so263197oia.11
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 23:48:58 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id r189si1730912oif.85.2017.09.28.23.48.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Sep 2017 23:48:57 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm: only dispaly online cpus of the numa node
References: <1497962608-12756-1-git-send-email-thunder.leizhen@huawei.com>
 <20170824083225.GA5943@dhcp22.suse.cz> <20170825173433.GB26878@arm.com>
 <20170828131328.GM17097@dhcp22.suse.cz>
From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Message-ID: <59CDEC59.8040102@huawei.com>
Date: Fri, 29 Sep 2017 14:46:49 +0800
MIME-Version: 1.0
In-Reply-To: <20170828131328.GM17097@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Catalin Marinas <catalin.marinas@arm.com>



On 2017/8/28 21:13, Michal Hocko wrote:
> On Fri 25-08-17 18:34:33, Will Deacon wrote:
>> On Thu, Aug 24, 2017 at 10:32:26AM +0200, Michal Hocko wrote:
>>> It seems this has slipped through cracks. Let's CC arm64 guys
>>>
>>> On Tue 20-06-17 20:43:28, Zhen Lei wrote:
>>>> When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
>>>> and display cpumask_of_node for each node), but I got different result on
>>>> X86 and arm64. For each numa node, the former only displayed online CPUs,
>>>> and the latter displayed all possible CPUs. Unfortunately, both Linux
>>>> documentation and numactl manual have not described it clear.
>>>>
>>>> I sent a mail to ask for help, and Michal Hocko <mhocko@kernel.org> replied
>>>> that he preferred to print online cpus because it doesn't really make much
>>>> sense to bind anything on offline nodes.
>>>
>>> Yes printing offline CPUs is just confusing and more so when the
>>> behavior is not consistent over architectures. I believe that x86
>>> behavior is the more appropriate one because it is more logical to dump
>>> the NUMA topology and use it for affinity setting than adding one
>>> additional step to check the cpu state to achieve the same.
>>>
>>> It is true that the online/offline state might change at any time so the
>>> above might be tricky on its own but if we should at least make the
>>> behavior consistent.
>>>
>>>> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
>>>
>>> Acked-by: Michal Hocko <mhocko@suse.com>
>>
>> The concept looks find to me, but shouldn't we use cpumask_var_t and
>> alloc/free_cpumask_var?
> 
> This will be safer but both callers of node_read_cpumap are shallow
> stack so I am not sure a stack is a limiting factor here.
> 
> Zhen Lei, would you care to update that part please?
> 
Sure, I will send v2 immediately.

I'm so sorry that missed this email until someone told me.

-- 
Thanks!
BestRegards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
