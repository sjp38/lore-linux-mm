Date: Thu, 16 Nov 2006 10:46:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
In-Reply-To: <20061116164037.58b3aaeb@localhost>
Message-ID: <Pine.LNX.4.64.0611161043510.28498@schroedinger.engr.sgi.com>
References: <20061115193049.3457b44c@localhost> <20061115193437.25cdc371@localhost>
 <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
 <20061115215845.GB20526@sgi.com> <Pine.LNX.4.64.0611151432050.23201@schroedinger.engr.sgi.com>
 <455B9825.3030403@mbligh.org> <Pine.LNX.4.64.0611151451450.23477@schroedinger.engr.sgi.com>
 <20061116095429.0e6109a7.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0611151653560.24565@schroedinger.engr.sgi.com>
 <20061116164037.58b3aaeb@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Krafft <krafft@de.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, mbligh@mbligh.org, steiner@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Nov 2006, Christian Krafft wrote:

> Okay, I slowly understand what you are talking about.
> I just tried a "numactl --cpunodebind 1 --membind 1 true" which hit an uninitialized zone in slab_node:
> 
> return zone_to_nid(policy->v.zonelist->zones[0]);

I think the above should work fine and give the expected OOM since the
node has no memory.

The zone struct should redirect via the zonelist to nodes that have 
memory for allocations that are not bound to a single node.

> I also still don't know if it makes sense to have memoryless nodes, but supporting it does.
> So wath would be reasonable, to have empty zonelists for those node, or to check if zonelists are uninitialized ?

zonelists of those nodes should contain a list of fallback zones with 
available memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
