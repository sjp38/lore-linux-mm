Date: Tue, 15 May 2007 21:20:27 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] Mark page cache pages as __GFP_PAGECACHE instead of
 __GFP_MOVABLE
In-Reply-To: <Pine.LNX.4.64.0705151303170.1712@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705152112160.16810@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150552.16348.15975.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705151130250.31972@schroedinger.engr.sgi.com>
 <20070515195206.GA14028@skynet.ie> <Pine.LNX.4.64.0705151303170.1712@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Christoph Lameter wrote:

> On Tue, 15 May 2007, Mel Gorman wrote:
>
>> Currently page cache pages are grouped with MOVABLE allocations. This appears
>> to work well in practice as page cache pages are usually reclaimable via
>> the LRU. However, this is not strictly correct as page cache pages can only
>> be cleaned and discarded, not migrated. During readahead, pages may also
>> exist on a pool for a period of time instead of on the LRU giving them a
>> differnet lifecycle to ordinary movable pages.
>
> Sorry but pagecache pages can be migrated.
>

Poor phrasing prehaps. I was under the impression that page migration was 
only concerned with pages mapped by process page tables for the 
move_pages() call. The statement above was also referring to pages read by 
readahead and normal file IO. I'm pretty sure they could be migrated 
without difficulty though once the source pages are identified. Either 
way, the separate grouping of page cache is probably not worthwhile for 
the moment.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
