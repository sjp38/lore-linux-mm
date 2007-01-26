Message-ID: <45BA49F2.2000804@nortel.com>
Date: Fri, 26 Jan 2007 12:35:30 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie> <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261649040.23091@skynet.skynet.ie> <Pine.LNX.4.64.0701260903110.6966@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261720120.23091@skynet.skynet.ie> <Pine.LNX.4.64.0701260921310.7301@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261727400.23091@skynet.skynet.ie> <Pine.LNX.4.64.0701260944270.7457@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0701261747290.23091@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0701261747290.23091@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> Worse, the problem is to have high order contiguous blocks free at the 
> time of allocation without reclaim or migration. If the allocations were 
> not atomic, anti-fragmentation as it is today would be enough.

Has anyone looked at marking the buffers as "needs refilling" then kick 
off a kernel thread or something to do the allocations under GFP_KERNEL? 
  That way we avoid having to allocate the buffers with GFP_ATOMIC.

I seem to recall that the tulip driver used to do this.  Is it just too 
complicated from a race condition standpoint?

We currently see this issue on our systems, as we have older e1000 
hardware with 9KB jumbo frames.  After a while we just fail to allocate 
buffers and the system goes belly-up.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
