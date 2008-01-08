Date: Tue, 8 Jan 2008 10:40:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-Id: <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
References: <20071220100541.GA6953@skywalker>
	<20071225140519.ef8457ff.akpm@linux-foundation.org>
	<20071227153235.GA6443@skywalker>
	<Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com>
	<20071228051959.GA6385@skywalker>
	<Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
	<20080103155046.GA7092@skywalker>
	<20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, nacc@us.ibm.com, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jan 2008 10:10:16 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 7 Jan 2008, KAMEZAWA Hiroyuki wrote:
> 
> > Seems Node 1 has no NORMAL memory.
> > 
> > Because the patch changes 'online_node' to N_NORMAL_MEMORY, there is a change.
> > I'm not sure but cachep->nodelists[] should be created against all online nodes ?
> 
> Well what is the point of creating a memory structure for a node from 
> which no memory for the slab allocator can be allocated? I think we need a 
> special cpu_to_node() that only takes normal memory into consideration. 
> 
In usual alloc_pages() allocator, this is done by zonelist fallback.

> And we need to use that new function (cpu_to_node_normal_memory or so?) to 
> find memory for the slab and other stuff in the kernel.
> 

It seems that cache->nodelists[nid] == NULL case should be handled even if
nid == cpu_to_node(smp_processor_id()). 

complicated ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
