Date: Fri, 26 Jan 2007 10:20:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
In-Reply-To: <Pine.LNX.4.64.0701261747290.23091@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0701261019210.7848@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261649040.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260903110.6966@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261720120.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260921310.7301@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261727400.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260944270.7457@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261747290.23091@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Mel Gorman wrote:

> The zone-based approach does nothing to help jumbo frame allocations. It only
> helps hugepage allocations at runtime and potentially memory hot-remove.

Sounds like the max order based approach is better in many ways. Also 
avoids modifications to vmstat.c/.h ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
