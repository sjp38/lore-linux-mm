Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C5D1A6B005A
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 17:42:07 -0500 (EST)
Message-ID: <50DCCE98.70000@oracle.com>
Date: Thu, 27 Dec 2012 17:41:28 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm, sparse: allocate bootmem without panicing in
 sparse_mem_maps_populate_node
References: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.00.1212271422280.18214@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1212271422280.18214@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/27/2012 05:23 PM, David Rientjes wrote:
> On Sun, 23 Dec 2012, Sasha Levin wrote:
> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 6b5fb76..72a0db6 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -401,7 +401,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>>  	}
>>  
>>  	size = PAGE_ALIGN(size);
>> -	map = __alloc_bootmem_node_high(NODE_DATA(nodeid), size * map_count,
>> +	map = __alloc_bootmem_node_high_nopanic(NODE_DATA(nodeid), size * map_count,
>>  					 PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
>>  	if (map) {
>>  		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> 
> What tree is this series based on?  There's no 
> __alloc_bootmem_node_high_nopanic() either in 3.8-rc1 nor in linux-next.
> 

This is me getting git-send-email wrong and forgetting the first patch that adds it.

Sorry, will resend.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
