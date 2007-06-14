Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5E04u1T018033
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 20:04:56 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5E04u6D258804
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 18:04:56 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5E04uqH020083
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 18:04:56 -0600
Date: Wed, 13 Jun 2007 17:04:54 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
Message-ID: <20070614000454.GB3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com> <1181769033.6148.116.camel@localhost> <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com> <20070613231153.GW3798@us.ibm.com> <Pine.LNX.4.64.0706131613050.394@schroedinger.engr.sgi.com> <20070613232005.GY3798@us.ibm.com> <Pine.LNX.4.64.0706131626250.698@schroedinger.engr.sgi.com> <20070613233256.GZ3798@us.ibm.com> <Pine.LNX.4.64.0706131649310.820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706131649310.820@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [16:53:26 -0700], Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Sorry, the real reason for wrapping the patches and reposting, for
> > me, is that we've had a lot of versions flying around, with small
> > fixlets here and there. I wanted to start a new thread for the 3 or
> > so patches I see that implement the core of dealing with memoryless
> > nodes, and then keep the discussion going there, but that was purely
> > for my own sanity.
> 
> Ok. I will try to put all the fixes together. Basically that will be
> the three patches plus Lee's new suggestion for alloc_pages_node. Plus
> fixes to slab / slub / the uncached allocator etc where I see that the
> online map is used but what was really intended was the
> node_memory_map. There is also stuff in the oom killer, vmscan.c etc
> that seems to make that assumption. Sigh.

Yeah, it's a big problem to solve, from an audit perspective.

> That still leaves the issue of the name.
> 
> node_memory

node_has_memory?

Reading code, if I see:

if (node_has_memory(nid))

it's almost reading an English sentence! :)

> set_node_has_memory
> set_node_no_memory

node_set_has_memory
node_set_no_memory?

Just to be close to (but not quite the same as) online/offline.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
