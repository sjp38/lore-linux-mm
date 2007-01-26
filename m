Date: Fri, 26 Jan 2007 13:25:14 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/8] Add __GFP_MOVABLE for callers to flag allocations
 that may be migrated
In-Reply-To: <45B9F3A3.6080003@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701261323390.19245@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234518.28809.86069.sendpatchset@skynet.skynet.ie>
 <45B9F3A3.6080003@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Nick Piggin wrote:

> Mel Gorman wrote:
>> It is often known at allocation time when a page may be migrated or
>> not. This patch adds a flag called __GFP_MOVABLE and a new mask called
>> GFP_HIGH_MOVABLE.
>
> Shouldn't that be HIGHUSER_MOVABLE?
>

I suppose, but it's a bit verbose. I don't feel very strongly about the 
name and the choice of name was taken from here - 
http://lkml.org/lkml/2006/11/23/157 . I can make it GFP_HIGHUSER_MOVABLE 
in the next revision

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
