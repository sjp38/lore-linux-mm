Date: Thu, 2 Aug 2007 13:26:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Audit of "all uses of node_online()"
In-Reply-To: <1186085994.5040.98.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070731203203.2691ca59.akpm@linux-foundation.org>  <1185977011.5059.36.camel@localhost>
  <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
 <1186085994.5040.98.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Lee Schermerhorn wrote:

> > Right. I think we first need to get the basic set straight. In order to be 
> > complete we need to audit all uses of node_online() in the kernel and 
> > think about those uses. They may require either N_NORMAL_MEMORY or 
> > N_HIGH_MEMORY depending on the check being for a page cache or a kernel 
> > allocation.
> 
> Below is a list of files in 23-rc1-mm2 with the memoryless nodes patches
> applied [the last ones I posted, not the most recent from Christoph's
> tree] that contain the strings 'node_online' or 'online_node'--i.e.
> possible uses of the node_online_map or the for_each_online_node macro.
> 48 files in all, I think.

Great thanks.
 
> Note that the list includes a lot of architectural dependent files.
> Shall I do a separate patch for each arch, so that arch maintainer can
> focus on that [I assume they'll want to review], or a single "jumbo
> patch" to reduce traffic?

Separate arch patches would be good.

> include/linux/topology.h
> mm/mempolicy.c
> 	? should BIND nodes be limited to nodes with memory?

Or it could automatically limit to those by anding with N_HIGH_MEMORY?

> 	? ALL policies in mpol_new()?
> 	? should mpol_check_policy() require a subset of nodes with memory?

Yea difficult question. What would be impact be if we require that? A node 
going down could cause the application to fail?

> mm/shmem.c
> 	fixed mount option parsing and superblock setup.
> mm/page-writeback.c
> 	fixed highmem_dirtyable_memory() to just look at N_MEMORY

N_HIGH_MEMORY right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
