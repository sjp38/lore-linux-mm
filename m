Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id kAGFhZLn192510
	for <linux-mm@kvack.org>; Thu, 16 Nov 2006 15:43:36 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAGFkjAL2580734
	for <linux-mm@kvack.org>; Thu, 16 Nov 2006 16:46:45 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAGFhR5k023578
	for <linux-mm@kvack.org>; Thu, 16 Nov 2006 16:43:27 +0100
Date: Thu, 16 Nov 2006 16:40:37 +0100
From: Christian Krafft <krafft@de.ibm.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
Message-ID: <20061116164037.58b3aaeb@localhost>
In-Reply-To: <Pine.LNX.4.64.0611151653560.24565@schroedinger.engr.sgi.com>
References: <20061115193049.3457b44c@localhost>
	<20061115193437.25cdc371@localhost>
	<Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
	<20061115215845.GB20526@sgi.com>
	<Pine.LNX.4.64.0611151432050.23201@schroedinger.engr.sgi.com>
	<455B9825.3030403@mbligh.org>
	<Pine.LNX.4.64.0611151451450.23477@schroedinger.engr.sgi.com>
	<20061116095429.0e6109a7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0611151653560.24565@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, mbligh@mbligh.org, steiner@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 16:57:56 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 16 Nov 2006, KAMEZAWA Hiroyuki wrote:
> 
> > > But there is no memory on the node. Does the zonelist contain the zones of 
> > > the node without memory or not? We simply fall back each allocation to the 
> > > next node as if the node was overflowing?
> > yes. just fallback.
> 
> Ok, so we got a useless pglist_data struct and the struct zone contains a 
> zonelist that does not include the zone.

Okay, I slowly understand what you are talking about.
I just tried a "numactl --cpunodebind 1 --membind 1 true" which hit an uninitialized zone in slab_node:

return zone_to_nid(policy->v.zonelist->zones[0]);

I also still don't know if it makes sense to have memoryless nodes, but supporting it does.
So wath would be reasonable, to have empty zonelists for those node, or to check if zonelists are uninitialized ?

-- 
Mit freundlichen Grussen,
kind regards,

Christian Krafft
IBM Systems & Technology Group, 
Linux Kernel Development
IT Specialist

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
