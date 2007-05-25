Date: Fri, 25 May 2007 10:02:07 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/5] Breakout page_order() to internal.h to avoid special
 knowledge of the buddy allocator
In-Reply-To: <Pine.LNX.4.64.0705241207260.30227@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705251001100.12364@skynet.skynet.ie>
References: <20070524190505.31911.42785.sendpatchset@skynet.skynet.ie>
 <20070524190546.31911.7469.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705241207260.30227@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Christoph Lameter wrote:

> On Thu, 24 May 2007, Mel Gorman wrote:
>
>> The statistics patch later needs to know what order a free page is on the
>> free lists. Rather than having special knowledge of page_private() when
>> PageBuddy() is set, this patch places out page_order() in internal.h and
>> adds a VM_BUG_ON to catch using it on non-PageBuddy pages.
>
> Ok but I think in the future we need to have some way to generally handle
> pages of higher order be they free or not. Maybe generalize the way we
> handle compound pages as done in the large blocksize patchset?
>

Ordinarily I would consider compound pages to be the general way 
high-order pages are handled - at least while they are allocated. I'll 
take a closer look again at what the blocksize patchset is doing.

> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
