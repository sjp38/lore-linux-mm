Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 061176B0044
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 02:07:28 -0400 (EDT)
Message-ID: <509212FC.8070802@cn.fujitsu.com>
Date: Thu, 01 Nov 2012 14:13:16 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART3 Patch 00/14] introduce N_MEMORY
References: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1210311112010.8809@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210311112010.8809@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

At 11/01/2012 02:16 AM, David Rientjes Wrote:
> On Wed, 31 Oct 2012, Wen Congyang wrote:
> 
>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>>
>> This patch is part3 of the following patchset:
>>     https://lkml.org/lkml/2012/10/29/319
>>
>> Part1 is here:
>>     https://lkml.org/lkml/2012/10/31/30
>>
>> Part2 is here:
>>     http://marc.info/?l=linux-kernel&m=135166705909544&w=2
>>
>> You can apply this patchset without the other parts.
>>
>> we need a node which only contains movable memory. This feature is very
>> important for node hotplug. So we will add a new nodemask
>> for all memory. N_MEMORY contains movable memory but N_HIGH_MEMORY
>> doesn't contain it.
>>
>> We don't remove N_HIGH_MEMORY because it can be used to search which
>> nodes contains memory that the kernel can use.
>>
> 
> This doesn't describe why we need the new node state, unfortunately.  It 

1. Somethimes, we use the node which contains the memory that can be used by
   kernel.
2. Sometimes, we use the node which contains the memory.

In case1, we use N_HIGH_MEMORY, and we use N_MEMORY in case2.

> makes sense to boot with node(s) containing only ZONE_MOVABLE, but it 
> doesn't show why we need a nodemask to specify such nodes and such 

Sorry for confusing you.
We don't add a nodemask to specify nodes which contain only ZONE_MOVABLE.
We want to add a nodemask(N_MEMORY) to specify nodes which contain memory.
In part3, we don't implement the node which only contain ZONE_MOVABLE, so
N_MEMORY is N_HIGH_MEMORY. We will add this nodemask when we implement
the node which contain only ZONE_MOVABLE.

In this patchset, we try to change N_HIGH_MEMORY to N_MEMORY for case2.

Thanks
Wen Congyang

> information should be available from the kernel log or /proc/zoneinfo.
> 
> Node hotplug should fail if all memory cannot be offlined, so why do we 
> need another nodemask?  Only offline the node if all memory is offlined.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
