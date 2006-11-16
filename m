Date: Thu, 16 Nov 2006 09:59:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
Message-Id: <20061116095945.e6ad4440.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0611151450550.23477@schroedinger.engr.sgi.com>
References: <20061115193049.3457b44c@localhost>
	<20061115193437.25cdc371@localhost>
	<Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
	<455B8F3A.6030503@mbligh.org>
	<Pine.LNX.4.64.0611151440400.23201@schroedinger.engr.sgi.com>
	<455B98AA.3040904@mbligh.org>
	<Pine.LNX.4.64.0611151450550.23477@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mbligh@mbligh.org, krafft@de.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 14:51:26 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 15 Nov 2006, Martin Bligh wrote:
> 
> > Supposing we hot-unplugged all the memory in a node? Or seems to have
> > happened in this instance is boot with mem=, cutting out memory on that
> > node.
> 
> So a node with no memory has a pgdat_list structure but no zones? Or empty 
> zones?
> 

The node has just empty-zone. pgdat/per-cpu-area is allocated on an other
(nearest) node.

I hear some vender's machine has this configuration. (ia64, maybe SGI or HP)

Node0: CPUx0 + XXXGb memory
Node1: CPUx2 + 16MB memory
Node2: CPUx2 + 16MB memory

memory of Node1 and Node2 is tirmmed at boot by GRANULE alignment.
Then, final view is
Node0 : memory-only-node
Node1 : cpu-only-node
Node2 : cpu-only-node.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
