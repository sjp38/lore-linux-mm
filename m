Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C1i1w0025832
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:44:01 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C1hxvq266808
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:44:01 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C1hxeh010625
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 19:43:59 -0600
Date: Mon, 11 Jun 2007 18:43:57 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070612014357.GD3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com> <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com> <20070612000705.GH14458@us.ibm.com> <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [17:41:15 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > > No need to initialize if we do not use it. You may to #ifdef it out
> > > by moving the definition. Please sent a diff against the earlier patch 
> > > since Andrew already merged it.
> > 
> > We will be using it (it == node_populated_mask) later in my sysfs patch
> > and in the fix hugepage allocation patch.
> 
> But not in the !NUMA case. So the definition of the node_populated_mask 
> can be moved into an #ifdef CONFIG_NUMA chunk in page_alloc.c and we can 
> have fallback functions.

Ah, but we'll use it in mpol_new via nodes_and() regardless of
NUMA/!NUMA, right?

I see no reason not make sure the node_populated_mask is sensible
whenever it can be.

If you really feel that only CONFIG_NUMA code should use
node_populated_mask, then I'll make that change and use node_populated()
in the callers.

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
