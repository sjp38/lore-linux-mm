Date: Thu, 28 Oct 2004 08:40:04 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: NUMA node swapping V3
Message-ID: <1275120000.1098978003@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.58.0410280820500.25586@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0410280820500.25586@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Changes from V2: better documentation, fix missing #ifdef
> 
> In a NUMA systems single nodes may run out of memory. This may occur even
> by only reading from files which will clutter node memory with cached
> pages from the file.
> 
> However, as long as the system as a whole does have enough memory
> available, kswapd is not run at all. This means that a process allocating
> memory and running on a node that has no memory left, will get memory
> allocated from other nodes which is inefficient to handle. It would be
> better if kswapd would throw out some pages (maybe some of the cached
> pages from files that have only once been read) to reclaim memory in the
> node.
> 
> The following patch checks the memory usage after each allocation in a
> zone. If the allocation in a zone falls below a certain minimum, kswapd is
> started for that zone alone.
> 
> The minimum may be controlled through /proc/sys/vm/node_swap which is set
> to zero by default and thus is off.
> 
> If it is set for example to 100 then kswapd will be run on
> a zone/node if less than 10% of pages are available after an allocation.

I thought even the SGI people were saying this wouldn't actually help you,
due to some workload issues?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
