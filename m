Date: Fri, 25 May 2007 10:03:36 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/5] Print out PAGE_OWNER statistics in relation to
 fragmentation avoidance
In-Reply-To: <Pine.LNX.4.64.0705241211340.30227@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705251002190.12364@skynet.skynet.ie>
References: <20070524190505.31911.42785.sendpatchset@skynet.skynet.ie>
 <20070524190646.31911.50248.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0705241211340.30227@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Christoph Lameter wrote:

> Not familiar with page owner handling. Sorry.
>

I don't think it exists outside of -mm.  While the information is not 
always available, it made sense to use it during debugging at least.

> Looks good though ;-)
>

Thanks.

> Acked-by: Christoph Lameter <clameter@sgi.com>
>

Thanks very much for reviewing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
