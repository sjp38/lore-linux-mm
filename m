Date: Tue, 15 May 2007 20:19:55 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/8] Do not depend on MAX_ORDER when grouping pages by
 mobility
In-Reply-To: <Pine.LNX.4.64.0705151118340.31972@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705152018280.12851@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150331.16348.18072.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705151118340.31972@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Christoph Lameter wrote:

> On Tue, 15 May 2007, Mel Gorman wrote:
>
>>
>>  #define SECTION_BLOCKFLAGS_BITS \
>> -		((1 << (PFN_SECTION_SHIFT - (MAX_ORDER-1))) * NR_PAGEBLOCK_BITS)
>> +	((1UL << (PFN_SECTION_SHIFT - pageblock_order)) * NR_PAGEBLOCK_BITS)
>>
>
> Ahh, Blockflags so this is not related to SPARSEMEM...
>

Only in that a bitmap is allocated per memory section instead of having a 
sparsely populated bitmap allocated for the zone.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
