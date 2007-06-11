Date: Mon, 11 Jun 2007 11:54:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
 are unpopulated
In-Reply-To: <20070611184656.GA9920@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111153170.18684@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
 <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org>
 <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
 <20070611171201.GB3798@us.ibm.com> <Pine.LNX.4.64.0706111122010.18327@schroedinger.engr.sgi.com>
 <20070611184656.GA9920@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Lee.Schermerhorn@hp.com, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> > +	do {
> > +		next = next_node(nid, policy->v.nodes);
> > +		if (next >= MAX_NUMNODES)
> > +			next = first_node(policy->v.nodes);
> > +	} while (!NODE_DATA(node)->present_pages);
> 
> If something like Lee/Anton's patch were to go in (which, as Lee pointed
> out, I refreshed as Patch 1/3 in the series I posted a few days ago),
> this would be
> 
> 	while(!node_populated(nid))

Right. That would be much better.

> Presuming I understand everything correctly. Not sure which would be
> preferred, or if perhaps node_populated, rather than using a nodemask
> should just use NODE_DATA(nid)->present_pages?

I think the node_populate is better. Simple bitmap lookup.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
