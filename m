Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 4D8826B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:36:17 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2219970pad.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 14:36:16 -0700 (PDT)
Date: Thu, 1 Nov 2012 14:36:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PART3 Patch 00/14] introduce N_MEMORY
In-Reply-To: <509212FC.8070802@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1211011431130.19373@chino.kir.corp.google.com>
References: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1210311112010.8809@chino.kir.corp.google.com> <509212FC.8070802@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

On Thu, 1 Nov 2012, Wen Congyang wrote:

> > This doesn't describe why we need the new node state, unfortunately.  It 
> 
> 1. Somethimes, we use the node which contains the memory that can be used by
>    kernel.
> 2. Sometimes, we use the node which contains the memory.
> 
> In case1, we use N_HIGH_MEMORY, and we use N_MEMORY in case2.
> 

Yeah, that's clear, but the question is still _why_ we want two different 
nodemasks.  I know that this part of the patchset simply introduces the 
new nodemask because the name "N_MEMORY" is more clear than 
"N_HIGH_MEMORY", but there's no real incentive for making that change by 
introducing a new nodemask where a simple rename would suffice.

I can only assume that you want to later use one of them for a different 
purpose: those that do not include nodes that consist of only 
ZONE_MOVABLE.  But that change for MPOL_BIND is nacked since it 
significantly changes the semantics of set_mempolicy() and you can't break 
userspace (see my response to that from yesterday).  Until that problem is 
addressed, then there's no reason for the additional nodemask so nack on 
this series as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
