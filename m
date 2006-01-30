Date: Mon, 30 Jan 2006 13:45:54 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Zone reclaim: Allow modification of zone reclaim
 behavior
Message-Id: <20060130134554.500b73a3.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0601301223350.4821@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0601301223350.4821@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> In some situations one may want zone_reclaim to behave differently. For
>  example a process writing large amounts of memory will spew unto other
>  nodes to cache the writes if many pages in a zone become dirty. This may
>  impact the performance of processes running on other nodes.
> 
>  Allowing writes during reclaim puts a stop to that behavior and throttles
>  the process by restricting the pages to the local zone.
> 
>  Similarly one may want to contain processes to local memory by enabling
>  regular swap behavior during zone_reclaim. Off node memory allocation
>  can then be controlled through memory policies and cpusets.

The proliferating /proc configurability is a worry.  It'll confuse people
and people just won't know that it's there and it's yet another question
which maintenance people need to ask end-users during problem resolution.

Is there not some means by which we can simply get these things right?

Why wouldn't we want to perform writeback or swapout during zone reclaim?

Why wouldn't we want to reclaim slab during zone reclaim?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
