Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l78MTL1Y007100
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 18:29:21 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l78NZnEY203214
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 17:35:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l78NZm5K026576
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 17:35:48 -0600
Date: Wed, 8 Aug 2007 16:35:47 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/14] Memoryless nodes: introduce mask of nodes with memory
Message-ID: <20070808233547.GG16588@us.ibm.com>
References: <20070804030100.862311140@sgi.com> <20070804030152.843011254@sgi.com> <20070808123804.d3b3bc79.akpm@linux-foundation.org> <20070808195514.GE16588@us.ibm.com> <20070808200349.GF16588@us.ibm.com> <Pine.LNX.4.64.0708081304370.14275@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708081304370.14275@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kxr@sgi.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Bob Picco <bob.picco@hp.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On 08.08.2007 [13:05:12 -0700], Christoph Lameter wrote:
> On Wed, 8 Aug 2007, Nishanth Aravamudan wrote:
> 
> > To try and remedy this -- I'll regrab this stack and rebase my patches
> > again. Test everything and resubmit mine.
> 
> Ummmm... These are the patches that you said you would test earlier.

Yes, sorry, I had leafed through the patches and didn't see any changes
and didn't see any subject changes indicated UPDATED or a new version,
so I incorrectly assumed that the patches were the same as before.

This stack has now been successfully compile & boot-tested on:

4-node x86 (NUMAQ), 1-node x86 (NUMAQ), !NUMA x86, 2-node IA64, 4-node
ppc64 (2 memoryless nodes).

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
