Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C1qSjD009518
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:52:28 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C1qSFi526384
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:52:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C1qSAP000926
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:52:28 -0400
Date: Mon, 11 Jun 2007 18:52:26 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070612015226.GE3798@us.ibm.com>
References: <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com> <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com> <20070612000705.GH14458@us.ibm.com> <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com> <20070612014357.GD3798@us.ibm.com> <Pine.LNX.4.64.0706111844560.24889@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111844560.24889@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [18:45:55 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > Ah, but we'll use it in mpol_new via nodes_and() regardless of
> > NUMA/!NUMA, right?
> 
> mempolicy.c will only be compiled for the NUMA case.

Ah, I did not realize that, sorry.

> > If you really feel that only CONFIG_NUMA code should use
> > node_populated_mask, then I'll make that change and use
> > node_populated() in the callers.
> 
> What point would there be of !NUMA configurations using
> node_populated_mask()?

Well, I'm just trying to cover all my bases. I will rework the stack to
be better and closer to what you'd like.

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
