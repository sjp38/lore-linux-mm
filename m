Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2859E6B0044
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 01:46:15 -0400 (EDT)
Message-ID: <50920E01.6060708@cn.fujitsu.com>
Date: Thu, 01 Nov 2012 13:52:01 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART2 Patch] node: cleanup node_state_attr
References: <1351666528-8226-1-git-send-email-wency@cn.fujitsu.com> <1351666528-8226-2-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1210311128570.8809@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210311128570.8809@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

At 11/01/2012 02:29 AM, David Rientjes Wrote:
> On Wed, 31 Oct 2012, Wen Congyang wrote:
> 
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index af1a177..5d7731e 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -614,23 +614,23 @@ static ssize_t show_node_state(struct device *dev,
>>  	{ __ATTR(name, 0444, show_node_state, NULL), state }
>>  
>>  static struct node_attr node_state_attr[] = {
>> -	_NODE_ATTR(possible, N_POSSIBLE),
>> -	_NODE_ATTR(online, N_ONLINE),
>> -	_NODE_ATTR(has_normal_memory, N_NORMAL_MEMORY),
>> -	_NODE_ATTR(has_cpu, N_CPU),
>> +	[N_POSSIBLE] = _NODE_ATTR(possible, N_POSSIBLE),
>> +	[N_ONLINE] = _NODE_ATTR(online, N_ONLINE),
>> +	[N_NORMAL_MEMORY] = _NODE_ATTR(has_normal_memory, N_NORMAL_MEMORY),
>>  #ifdef CONFIG_HIGHMEM
>> -	_NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
>> +	[N_HIGH_MEMORY] = _NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
>>  #endif
>> +	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
>>  };
>>  
> 
> Why change the index for N_CPU?

N_CPU > N_HIGH_MEMORY

We use this array to create attr file in sysfs. So changing the index for N_CPU
doesn't cause any other problem.

Thanks
Wen Congyang

> 
>>  static struct attribute *node_state_attrs[] = {
>> -	&node_state_attr[0].attr.attr,
>> -	&node_state_attr[1].attr.attr,
>> -	&node_state_attr[2].attr.attr,
>> -	&node_state_attr[3].attr.attr,
>> +	&node_state_attr[N_POSSIBLE].attr.attr,
>> +	&node_state_attr[N_ONLINE].attr.attr,
>> +	&node_state_attr[N_NORMAL_MEMORY].attr.attr,
>>  #ifdef CONFIG_HIGHMEM
>> -	&node_state_attr[4].attr.attr,
>> +	&node_state_attr[N_HIGH_MEMORY].attr.attr,
>>  #endif
>> +	&node_state_attr[N_CPU].attr.attr,
>>  	NULL
>>  };
>>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
