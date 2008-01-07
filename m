Date: Mon, 7 Jan 2008 10:10:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG]  at mm/slab.c:3320
In-Reply-To: <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com>
References: <20071220100541.GA6953@skywalker> <20071225140519.ef8457ff.akpm@linux-foundation.org>
 <20071227153235.GA6443@skywalker> <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com>
 <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
 <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, nacc@us.ibm.com, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jan 2008, KAMEZAWA Hiroyuki wrote:

> Seems Node 1 has no NORMAL memory.
> 
> Because the patch changes 'online_node' to N_NORMAL_MEMORY, there is a change.
> I'm not sure but cachep->nodelists[] should be created against all online nodes ?

Well what is the point of creating a memory structure for a node from 
which no memory for the slab allocator can be allocated? I think we need a 
special cpu_to_node() that only takes normal memory into consideration. 

And we need to use that new function (cpu_to_node_normal_memory or so?) to 
find memory for the slab and other stuff in the kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
