Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC976B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 04:13:20 -0400 (EDT)
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.DEB.1.00.0909220023070.9061@chino.kir.corp.google.com>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
	 <1253577603.7103.174.camel@pasglop>
	 <alpine.DEB.1.00.0909211704180.4798@chino.kir.corp.google.com>
	 <alpine.DEB.1.10.0909220227050.3719@V090114053VZO-1>
	 <alpine.DEB.1.00.0909220023070.9061@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Tue, 22 Sep 2009 18:11:17 +1000
Message-Id: <1253607077.7103.219.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-09-22 at 00:59 -0700, David Rientjes wrote:
> The equivalent of proximity domains then describes the distance between 
> all localities; these distances need not be one-way, it is possible for 
> distance in one direction to be different from the opposite direction, 
> just as ACPI pxm's allow.
> 
> A "node" in this plan is simply a system locality consisting of memory.
> 
> For subsystems such as slab allocators, all we require is cpu_to_node() 
> tables which would map cpu localities to nodes and describe them in terms 
> of local or remote distance (or whatever the SLIT says, if provided).  All 
> present day information can still be represented in this model, we've just 
> added additional layers of abstraction internally.

While I like the idea of NUMA nodes being strictly memory and everything
else being expressed by distances, we'll have to clean up quite a few
corners with skeletons in various states of decompositions waiting for
us there.

For example, we have code here or there that (ab)uses the NUMA node
information to link devices with their iommu, that sort of thing. IE, a
hard dependency which isn't really related to a concept of distance to
any memory.

At least on powerpc, nowadays, I can pretty much make everything
fallback to some representation in the device-tree though, thus it
shouldn't be -that- hard to fix I suppose.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
