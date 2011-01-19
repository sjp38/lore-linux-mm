Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BD3C18D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 14:59:07 -0500 (EST)
Date: Wed, 19 Jan 2011 13:59:01 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
 is not allowed
In-Reply-To: <alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1101191351010.20403@router.home>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com> <alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1101191351012.20403@router.home>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011, David Rientjes wrote:

> It depends on the semantics of NUMA_MISS: if no local nodes are allowed by
> current's cpuset (a pretty poor cpuset config :), then it seems logical
> that all allocations would be a miss.

NUMA_MISS is defined as an allocations that did not succeed on the node
the allocation was "intended" for. So far "intended" as been interpreted
as allocations that are either intended for the closest numa node or the
preferred node. One could say that the cpuset config is an "intention".

Andi?


See man numastat


NAME
       numastat - Print statistics about NUMA memory allocation

SYNOPSIS
       numastat

DESCRIPTION
       numastat  displays  NUMA allocations statistics from the kernel
memory allocator.  Each process has NUMA policies that specifies on which
node pages are allocated.
       See set_mempolicy(2) or numactl(8) on details of the available
policies.  The numastat counters keep track on what nodes memory is
finally allocated.

       The counters are separated for each node. Each count event is the
allocation of a page of memory.

       numa_hit is the number of allocations where an allocation was
intended for that node and succeeded there.

       numa_miss shows how often an allocation was intended for this node,
but ended up on another node due to low memory.

       numa_foreign is the number of allocations that were intended for
another node, but ended up on this node.  Each numa_foreign event has a
numa_miss on another node.

       interleave_hit is the number of interleave policy allocations that
were intended for a specific node and succeeded there.

       local_node is incremented when a process running on the node
allocated memory on the same node.

       other_node is incremented when a process running on another node
allocated memory on that node.

SEE ALSO
       numactl(8) set_mempolicy(2) numa(3)

NOTES
       numastat output is only available on NUMA systems.

       numastat assumes the output terminal has a width of 80 characters
and tries to format the output accordingly.

EXAMPLES
       watch -n1 numastat
       watch -n1 --differences=accumulative numastat

FILES
       /sys/devices/system/node/node*/numastat


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
