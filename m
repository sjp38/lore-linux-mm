Date: Mon, 23 Jul 2007 12:23:27 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v4][RFC] hugetlb: add per-node nr_hugepages sysfs
 attribute
Message-ID: <20070723122327.3610adf4@schroedinger.engr.sgi.com>
In-Reply-To: <1181765111.6148.98.camel@localhost>
References: <20070612001542.GJ14458@us.ibm.com>
	<20070612034407.GB11773@holomorphy.com>
	<20070612050910.GU3798@us.ibm.com>
	<20070612051512.GC11773@holomorphy.com>
	<20070612174503.GB3798@us.ibm.com>
	<20070612191347.GE11781@holomorphy.com>
	<20070613000446.GL3798@us.ibm.com>
	<20070613152649.GN3798@us.ibm.com>
	<20070613152847.GO3798@us.ibm.com>
	<1181759027.6148.77.camel@localhost>
	<20070613191908.GR3798@us.ibm.com>
	<1181765111.6148.98.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007 16:05:10 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> I tried to "tighten up"  alloc_pages_node() to check the location of
> the first zone in the selected zonelist, as discussed in previous
> exchange. When I do this, I hit a BUG() in slub.c in
> early_kmem_cache_node_alloc(), as it apparently can't handle
> new_slab() returning a NULL page, even tho' it calls it with
> GFP_THISNODE.  Slub should be able to handle memoryless nodes,
> right?  I'm looking for a work around to this now.

The memoryless node patchset results in SLUB not attempting to allocate
on memoryless nodes during bootstrap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
