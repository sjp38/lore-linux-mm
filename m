Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 7ED536B006E
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 21:55:34 -0500 (EST)
Message-ID: <50A5AC9B.7000107@cn.fujitsu.com>
Date: Fri, 16 Nov 2012 11:01:47 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART3 Patch v2 13/14] page_alloc: use N_MEMORY instead N_HIGH_MEMORY
 change the node_states initialization
References: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>	<1352969857-26623-14-git-send-email-wency@cn.fujitsu.com> <20121115162920.af46d08a.akpm@linux-foundation.org>
In-Reply-To: <20121115162920.af46d08a.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Lin feng <linfeng@cn.fujitsu.com>

At 11/16/2012 08:29 AM, Andrew Morton Wrote:
> On Thu, 15 Nov 2012 16:57:36 +0800
> Wen Congyang <wency@cn.fujitsu.com> wrote:
> 
>> N_HIGH_MEMORY stands for the nodes that has normal or high memory.
>> N_MEMORY stands for the nodes that has any memory.
>>
>> The code here need to handle with the nodes which have memory, we should
>> use N_MEMORY instead.
>>
>> Since we introduced N_MEMORY, we update the initialization of node_states.
> 
> reset_zone_present_pages() has been removed by the recently-queued
> revert-mm-fix-up-zone-present-pages.patch, so I dropped that hunk.
> 
> We still have
> 
> akpm:/usr/src/25> grep N_HIGH_MEMORY mm/page_alloc.c
>         [N_HIGH_MEMORY] = { { [0] = 1UL } },
>                         node_set_state(nid, N_HIGH_MEMORY);
>                         if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&
> 
> which I hope is correct.  Can you please check it?
> 

Yes, it is correct.

We will introduce N_MEMORY nodemask in part4, and N_MEMORY is N_HIGH_MEMORY
in this patchset. So we don't init and update N_MEMORY nodemask in this patchset.

Thanks
Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
