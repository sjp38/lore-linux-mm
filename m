Date: Wed, 15 Nov 2006 16:57:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
In-Reply-To: <20061116095429.0e6109a7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0611151653560.24565@schroedinger.engr.sgi.com>
References: <20061115193049.3457b44c@localhost> <20061115193437.25cdc371@localhost>
 <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
 <20061115215845.GB20526@sgi.com> <Pine.LNX.4.64.0611151432050.23201@schroedinger.engr.sgi.com>
 <455B9825.3030403@mbligh.org> <Pine.LNX.4.64.0611151451450.23477@schroedinger.engr.sgi.com>
 <20061116095429.0e6109a7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: mbligh@mbligh.org, steiner@sgi.com, krafft@de.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Nov 2006, KAMEZAWA Hiroyuki wrote:

> > But there is no memory on the node. Does the zonelist contain the zones of 
> > the node without memory or not? We simply fall back each allocation to the 
> > next node as if the node was overflowing?
> yes. just fallback.

Ok, so we got a useless pglist_data struct and the struct zone contains a 
zonelist that does not include the zone.

numa_node_id() points to this and we always get allocations redirected to 
other nodes. The slab duplicates its per node structures on the fallback 
node.

> The zonelist[] donen't contain empty-zone.

So we will never encounter that zone except when going to the 
pglist_data struct through numa_node_id()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
