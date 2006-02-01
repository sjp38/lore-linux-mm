Message-ID: <43E04567.5070603@jp.fujitsu.com>
Date: Wed, 01 Feb 2006 14:21:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] remove zone_mem_map [3/4] pfn_to_page()
References: <43E02AAC.7050104@jp.fujitsu.com> <43E04206.8030104@mbligh.org>
In-Reply-To: <43E04206.8030104@mbligh.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
> KAMEZAWA Hiroyuki wrote:
>> Replace page_to_pfn() functions which uses zone->zone_mem_map.
>>
>> Although pfn_to_page() uses node->node_mem_map, page_to_pfn() uses
>> zone->zone_mem_map. I don't know why. This patch make page_to_pfn
>> use node->node_mem_map
> 
> I think that might have been because it's a faster op, at least on
> some architectures, under sparsemem. Andy, can you confirm / deny?
> Some part of the mapping was embedded in the page flags.
> 
Under sparsemem, zone->zone_mem_map is meaningless.
The mem_map is not contiguous.

If NODE_DATA(nid) is slower than page_zone() , this change will be problem.
While page_zone() accesses global zone_table[], NODE_DATA(nid) depends on each
arch. Some archs has local NODE_DATA table.

> If Andy can't recall, I'll look again on Thursday when I'm back ...
> 
> M.
> 
Thank you!.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
