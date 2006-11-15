Date: Wed, 15 Nov 2006 15:58:45 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have no memory
Message-ID: <20061115215845.GB20526@sgi.com>
References: <20061115193049.3457b44c@localhost> <20061115193437.25cdc371@localhost> <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christian Krafft <krafft@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 15, 2006 at 01:24:55PM -0800, Christoph Lameter wrote:
> On Wed, 15 Nov 2006, Christian Krafft wrote:
> 
> > When booting a NUMA system with nodes that have no memory (eg by limiting memory),
> > bootmem_alloc_core tried to find pages in an uninitialized bootmem_map.
> 
> Why should we support nodes with no memory? If a node has no memory then 
> its processors and other resources need to be attached to the nearest node 
> with memory.
> 
> AFAICT The primary role of a node is to manage memory.
> 

SGI has nodes that are have neither memory or cpus. These are
IO nodes. Think of them as ordinary nodes that have had the 
cpu's & DIMMs removed. Only the IO buses remain. 

IO nodes have the same NUMA properties as regular nodes.
They are connected via the numalink fabric, they should be described
in the SLIT table, they should be identified in proximity_domains, etc.

A lot of the core infrastructure is currently missing that is required
to describe IO nodes as regular nodes, but in principle, I don't
see anything wrong with nodes w/o memory.


It is also possible to disable the DIMMs on a node that actually has
cpus & memory. I suspect this doesn't work but I see no reason that you 
should HAVE to disable the cpus on nodes that have had the DIMMs disabled. 
Our BIOS currently provides the capability to disable DIMMS. The BIOS has
a hack to automatically disable cpus if all DIMMs have been disabled.
This hack was required for several reasons, one of which was linux does
not support nodes with cpus & no memory.



-- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
