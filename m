Date: Tue, 15 May 2007 11:25:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/8] Print out statistics in relation to fragmentation
 avoidance to /proc/fragavoidance
In-Reply-To: <20070515150351.16348.14242.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0705151122110.31972@schroedinger.engr.sgi.com>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150351.16348.14242.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007, Mel Gorman wrote:

> 
> This patch provides fragmentation avoidance statistics via
> /proc/fragavoidance. The information is collected only on request so there

The name is probably a bit strange.

/proc/pagetypeinfo or so?

> The first part is a more detailed version of /proc/buddyinfo and looks like
> 
> Free pages count per migrate type
If you have a header ^^^ then maybe add order on top of the numbers?
> Node 0, zone      DMA, type    Unmovable      0      0      0      0      0      0      0      0      0      0      0
> Node 0, zone      DMA, type  Reclaimable      1      0      0      0      0      0      0      0      0      0      0
> Node 0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      0
> Node 0, zone      DMA, type      Reserve      0      4      4      0      0      0      0      1      0      1      0
> Node 0, zone   Normal, type    Unmovable    111      8      4      4      2      3      1      0      0      0      0
> Node 0, zone   Normal, type  Reclaimable    293     89      8      0      0      0      0      0      0      0      0
> Node 0, zone   Normal, type      Movable      1      6     13      9      7      6      3      0      0      0      0
> Node 0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      4
> 
> The second part looks like
> 
> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve
> Node 0, zone      DMA            0            1            2            1
> Node 0, zone   Normal            3           17           94            4

What is "blocks"? maxorder blocks? how do I figure out the blocksize? 
Could you include the blocksize here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
