Date: Tue, 15 May 2007 20:23:21 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/8] Print out statistics in relation to fragmentation
 avoidance to /proc/fragavoidance
In-Reply-To: <Pine.LNX.4.64.0705151122110.31972@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705152020140.12851@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150351.16348.14242.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705151122110.31972@schroedinger.engr.sgi.com>
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
>> This patch provides fragmentation avoidance statistics via
>> /proc/fragavoidance. The information is collected only on request so there
>
> The name is probably a bit strange.
>
> /proc/pagetypeinfo or so?
>

/proc/mobilityinfo ?

>> The first part is a more detailed version of /proc/buddyinfo and looks like
>>
>> Free pages count per migrate type
> If you have a header ^^^ then maybe add order on top of the numbers?

I can do that.

>> Node 0, zone      DMA, type    Unmovable      0      0      0      0      0      0      0      0      0      0      0
>> Node 0, zone      DMA, type  Reclaimable      1      0      0      0      0      0      0      0      0      0      0
>> Node 0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      0
>> Node 0, zone      DMA, type      Reserve      0      4      4      0      0      0      0      1      0      1      0
>> Node 0, zone   Normal, type    Unmovable    111      8      4      4      2      3      1      0      0      0      0
>> Node 0, zone   Normal, type  Reclaimable    293     89      8      0      0      0      0      0      0      0      0
>> Node 0, zone   Normal, type      Movable      1      6     13      9      7      6      3      0      0      0      0
>> Node 0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      4
>>
>> The second part looks like
>>
>> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve
>> Node 0, zone      DMA            0            1            2            1
>> Node 0, zone   Normal            3           17           94            4
>
> What is "blocks"? maxorder blocks? how do I figure out the blocksize?
> Could you include the blocksize here?
>

Each block contains nr_pages_pageblock number of pages. The number of 
pages can be determined from the dmesg output like;

Built 1 zonelists, mobility grouping on order 10.

In that case, nr_pages_pageblock would be (1UL << 10).

However, the information can be printed here as well as whether mobility 
is on or not.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
