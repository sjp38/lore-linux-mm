Date: Tue, 31 Jul 2007 20:37:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
In-Reply-To: <20070731203203.2691ca59.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707312033560.22893@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070731203203.2691ca59.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Andrew Morton wrote:

> > Andi wants to drop support for NUMAQ again. Is that possible? NUMA only on 
> > 64 bit?
> 
> umm, that would need wide circulation.  I have a feeling that some
> implementations of some of the more obscure 32-bit architectures can (or
> will) have numa characteristics.  Looks like mips might already.
> 
> And doesn't i386 summit do numa?
> 
> We could do it, but it would take some chin-scratching.  It'd be good if we
> could pull it off.

Ok then we need to support highmem only nodes.

New flag:

N_HIGHMEMORY

N_HIGHMEMORY means any memory. N_MEMORY means normal memory.

slab etc needs to use N_MEMORY.

pagecache / memory policies can use N_HIGHMEMORY

Or do we want N_SLAB so that we can control which nodes are used by the 
slab allocators?

The effect of memory policies will vary depending on where normal memory 
is available.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
