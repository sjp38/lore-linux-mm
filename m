Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C2YO4l005369
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:34:24 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C2YO1M433252
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:34:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C2YNBJ009991
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:34:23 -0400
Date: Mon, 11 Jun 2007 19:34:21 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612023421.GL3798@us.ibm.com>
References: <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com> <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [19:25:08 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Christoph Lameter wrote:
> 
> > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > 
> > > static int nid = first_node(node_populated_map), I get:
> > > 
> > > mm/hugetlb.c:108: error: initializer element is not constant
> > 
> > Remove the static.
> 
> Cutting down the CCs.
> 
> Removing static wont help if the variable is still global. You need to 
> define a local variable. Then it can be initialized with a variable 
> expression.

What global?

nid is static to alloc_fresh_huge_page().

gcc says that the static variable (which *must* be static for the
current round-robin allocation method) cannot be initialized with a
non-constant (which first_node is).

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
