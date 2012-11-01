Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 5CE8E6B0089
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:29:44 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2216694pad.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 14:29:43 -0700 (PDT)
Date: Thu, 1 Nov 2012 14:29:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PART2 Patch] node: cleanup node_state_attr
In-Reply-To: <50920E01.6060708@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1211011429240.19373@chino.kir.corp.google.com>
References: <1351666528-8226-1-git-send-email-wency@cn.fujitsu.com> <1351666528-8226-2-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1210311128570.8809@chino.kir.corp.google.com> <50920E01.6060708@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

On Thu, 1 Nov 2012, Wen Congyang wrote:

> >> diff --git a/drivers/base/node.c b/drivers/base/node.c
> >> index af1a177..5d7731e 100644
> >> --- a/drivers/base/node.c
> >> +++ b/drivers/base/node.c
> >> @@ -614,23 +614,23 @@ static ssize_t show_node_state(struct device *dev,
> >>  	{ __ATTR(name, 0444, show_node_state, NULL), state }
> >>  
> >>  static struct node_attr node_state_attr[] = {
> >> -	_NODE_ATTR(possible, N_POSSIBLE),
> >> -	_NODE_ATTR(online, N_ONLINE),
> >> -	_NODE_ATTR(has_normal_memory, N_NORMAL_MEMORY),
> >> -	_NODE_ATTR(has_cpu, N_CPU),
> >> +	[N_POSSIBLE] = _NODE_ATTR(possible, N_POSSIBLE),
> >> +	[N_ONLINE] = _NODE_ATTR(online, N_ONLINE),
> >> +	[N_NORMAL_MEMORY] = _NODE_ATTR(has_normal_memory, N_NORMAL_MEMORY),
> >>  #ifdef CONFIG_HIGHMEM
> >> -	_NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
> >> +	[N_HIGH_MEMORY] = _NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
> >>  #endif
> >> +	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
> >>  };
> >>  
> > 
> > Why change the index for N_CPU?
> 
> N_CPU > N_HIGH_MEMORY
> 
> We use this array to create attr file in sysfs. So changing the index for N_CPU
> doesn't cause any other problem.
> 

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
