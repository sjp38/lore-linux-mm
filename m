Date: Mon, 11 Jun 2007 17:47:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612001542.GJ14458@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
 <20070612001542.GJ14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> On 11.06.2007 [16:17:47 -0700], Christoph Lameter wrote:
> > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > 
> > > +	if (nid < 0)
> > > +		nid = first_node(node_populated_map);
> > 
> > nid == 1 means local node? Or why do we check for nid < 0?
> > 
> > 	if (nid == 1)
> > 		 nid = numa_node_id();
> > 
> > ?
> 
> No, nid is a static variable. So we initialize it to -1 to catch the
> first time we go through the loop.
> 
> IIRC, we can't just set it to first_node(node_populated_map), because
> it's a non-constant or something?

Sure, you can initialize a c variable from another. So drop the -1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
