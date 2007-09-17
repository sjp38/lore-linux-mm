Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H6kQuM007191
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 16:46:26 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H6miqT062156
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 16:48:45 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H6irDg009963
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 16:44:54 +1000
Message-ID: <46EE2247.2020407@linux.vnet.ibm.com>
Date: Mon, 17 Sep 2007 12:14:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 0/14] Page Reclaim Scalability
References: <20070914205359.6536.98017.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

[snip]

> 
> Aside:  I note that in 23-rc4-mm1, the memory controller has 
> its own active and inactive list.  It may also benefit from
> use of Christoph's patch.  Further, we'll need to consider 
> whether memory controllers should maintain separate noreclaim
> lists.
> 

I need to look at the patches, but if the per zone LRU is going
to benefit, it is likely that the memory controller will benefit
from the split. We plan to do an mlock() controller, so we will
definitely gain from the noreclaim lists. The mlock() controller
will put a limit on the amount of mlocked memory and reclaim in
general will benefit from noreclaim lists, especially if the locked
memory proportion is significant.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
