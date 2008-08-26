Message-ID: <48B46917.6080304@sgi.com>
Date: Tue, 26 Aug 2008 13:35:35 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of
 CPUs
References: <20080821183648.22AF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <48B2FE79.8060709@sgi.com> <20080826083243.232F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080826083243.232F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>>> +	int node = numa_node_id();
>>> +	struct zone *zones = NODE_DATA(node)->node_zones;
>>> +	int num_cpus_on_node;
>>> +	node_to_cpumask_ptr(cpumask_on_node, node);
>>>  
>>>  	node_free_pages =
>>>  #ifdef CONFIG_ZONE_DMA
>>> @@ -38,6 +41,10 @@ static unsigned long max_pages(unsigned 
>>>  		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
>>>  
>>>  	max = node_free_pages / FRACTION_OF_NODE_MEM;
>>> +
>>> +	num_cpus_on_node = cpus_weight_nr(*cpumask_on_node);
>>> +	max /= num_cpus_on_node;
>>> +
>>>  	return max(max, min_pages);
>> Exactly!  And (many thanks to them!) the sparc maintainers have
>> implemented a similar internal function definition for node_to_cpumask_ptr().
> 
> Can I think get your Ack?
> 

Based on code review, sure.  I'll also give it a try on one of my
test machines as soon as I can.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
