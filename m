Message-ID: <43E0B8EE.7050306@shadowen.org>
Date: Wed, 01 Feb 2006 13:34:38 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] remove zone_mem_map [3/4] pfn_to_page()
References: <43E02AAC.7050104@jp.fujitsu.com> <43E04206.8030104@mbligh.org>
In-Reply-To: <43E04206.8030104@mbligh.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
> KAMEZAWA Hiroyuki wrote:
> 
>> Replace page_to_pfn() functions which uses zone->zone_mem_map.
>>
>> Although pfn_to_page() uses node->node_mem_map, page_to_pfn() uses
>> zone->zone_mem_map. I don't know why. This patch make page_to_pfn
>> use node->node_mem_map
> 
> 
> I think that might have been because it's a faster op, at least on
> some architectures, under sparsemem. Andy, can you confirm / deny?
> Some part of the mapping was embedded in the page flags.
> 
> If Andy can't recall, I'll look again on Thursday when I'm back ...

Not for SPARSEMEM anyhow, we don't use any of those pointers we are
using the per section maps based on pfn.  However, I would assume we
have it as an optimisation for the FLAT/DISCONTIG forms -- as we have a
quick lookup of the zone.  That said we should have a quick lookup of
the node too and it looks like the proposed replacement is using that
one.  So I'd say this should be about as performant.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
