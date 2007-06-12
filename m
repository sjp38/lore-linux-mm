Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C1A3ch017837
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:10:03 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C2Cmur531742
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:12:48 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C2CloL011958
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:12:48 -0400
Date: Mon, 11 Jun 2007 19:12:45 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612021245.GH3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [17:47:41 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > On 11.06.2007 [16:17:47 -0700], Christoph Lameter wrote:
> > > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > > 
> > > > +	if (nid < 0)
> > > > +		nid = first_node(node_populated_map);
> > > 
> > > nid == 1 means local node? Or why do we check for nid < 0?
> > > 
> > > 	if (nid == 1)
> > > 		 nid = numa_node_id();
> > > 
> > > ?
> > 
> > No, nid is a static variable. So we initialize it to -1 to catch the
> > first time we go through the loop.
> > 
> > IIRC, we can't just set it to first_node(node_populated_map), because
> > it's a non-constant or something?
> 
> Sure, you can initialize a c variable from another. So drop the -1.

If I do:

static int nid = first_node(node_populated_map), I get:

mm/hugetlb.c:108: error: initializer element is not constant

??

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
