Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6PFuQHE002043
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 11:56:26 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6PFuQdO503374
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 11:56:26 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6PFuQrH026323
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 11:56:26 -0400
Date: Wed, 25 Jul 2007 08:56:21 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH/RFC] Memoryless nodes:  Suppress redundant "node with no memory" messages
Message-ID: <20070725155621.GF18510@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182250.005856256@sgi.com> <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com> <1185309313.5649.75.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1185309313.5649.75.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 24.07.2007 [16:35:13 -0400], Lee Schermerhorn wrote:
> Suppress redundant "node with no memory" messages
> 
> Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless
> node series.
> 
> get_pfn_range_for_nid() is called multiple times for each node
> at boot time.  Each time, it will warn about nodes with no
> memory, resulting in boot messages like:
> 
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	On node 0 totalpages: 0
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	  DMA zone: 0 pages used for memmap
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	  Normal zone: 0 pages used for memmap
> 	Node 0 active with no memory
> 	Node 0 active with no memory
> 	  Movable zone: 0 pages used for memmap
> 
> and so on for each memoryless node.  Track [in init data]
> memoryless nodes that we've already reported to suppress
> the redundant messages.
> 
> OR, we could eliminate the message altogether?  We do
> report zero totalpages.  Sufficient?

Not being an expert, I honestly don't know. But I do think it's quite
clear that we only need one or the other type of message (presuming both
are always shown, that is neither can somehow already be disabled), as
they say the same thing :) I found this to be odd behavior too.

> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
