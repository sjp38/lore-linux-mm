Date: Tue, 31 Jul 2007 19:22:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
Message-Id: <20070731192241.380e93a0.akpm@linux-foundation.org>
In-Reply-To: <20070727194322.18614.68855.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	<20070727194322.18614.68855.sendpatchset@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jul 2007 15:43:22 -0400 Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> [patch 1/14] NUMA: Generic management of nodemasks for various purposes
> 
> Preparation for memoryless node patches.
> 
> Provide a generic way to keep nodemasks describing various characteristics
> of NUMA nodes.
> 
> Remove the node_online_map and the node_possible map and realize the whole
> thing using two nodes stats: N_POSSIBLE and N_ONLINE.
> 
> ...
>
> +#define for_each_node_state(node, __state) \
> +	for ( (node) = 0; (node) != 0; (node) = 1)

That looks weird.



This patch causes early crashes on i386.

http://userweb.kernel.org/~akpm/dsc03671.jpg
http://userweb.kernel.org/~akpm/config-vmm.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
