Date: Tue, 12 Jun 2007 11:45:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
In-Reply-To: <1181657940.5592.19.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com>  <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <1181657940.5592.19.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Lee Schermerhorn wrote:

> > Could be much simpler:
> > 
> > if (pgdat->node_present_pages)
> > 	node_set_populated(local_node);
> 
> As a minimum, we need to exclude a node with only zone DMA memory for
> this to work on our platforms.  For that, I think the current code is
> the simplest because we still need to check if the first zone is
> "on-node" and !DMA.

You are changing the definition of populated node.

> And, I think we need both cases--set and reset populated map bit--to
> handle memory/node hotplug.  So something like:

Yes memory unplug will need to clear the bit if a complete node is
cleared. But we do not support node unplug yet. So it is okay for now and 
it is doubtful that the build_zonelist function is going to be called for 
the node that is being removed.

> Need to define 'is_zone-dma()' to test the zone or unconditionally
> return false depending on whether ZONE_DMA is configured.

CONFIG_ZONE_DMA already exists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
