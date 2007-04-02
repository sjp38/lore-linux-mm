Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l32M5BsG007963
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 18:05:11 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l32M5ASC194628
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 16:05:10 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l32M5952000354
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 16:05:10 -0600
Subject: Re: [PATCH 1/2] Generic Virtual Memmap suport for SPARSEMEM
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704021449200.2272@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
	 <1175547000.22373.89.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021351590.1224@schroedinger.engr.sgi.com>
	 <1175548924.22373.109.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021428340.2272@schroedinger.engr.sgi.com>
	 <1175550151.22373.116.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021449200.2272@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 02 Apr 2007 15:05:05 -0700
Message-Id: <1175551505.22373.126.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 14:53 -0700, Christoph Lameter wrote:
> > > Well think about how to handle the case that the allocatiopn of a page 
> > > table page or a vmemmap block fails. Once we have that sorted out then we 
> > > can cleanup the higher layers.
> > 
> > I think it is best to just completely replace
> > sparse_early_mem_map_alloc() for the vmemmap case.  It really is a
> > completely different beast.  You'd never, for instance, have
> > alloc_remap() come into play.
> 
> What is the purpose of alloc_remap? Could not figure that one out.

That's what we use on i386 to get some lowmem area for non-zero NUMA
nodes.  Otherwise, all of ZONE_NORMAL is on node 0.  It's a bit hokey,
and stuff like virt_to_phys() probably doesn't work on it, but it has
worked pretty well for a long time.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
