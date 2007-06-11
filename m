Date: Mon, 11 Jun 2007 11:40:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
 are unpopulated
In-Reply-To: <1181586222.8324.78.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706111139370.18327@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
 <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org>
 <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
 <1181586222.8324.78.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Nishanth Aravamudan <nacc@us.ibm.com>, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Lee Schermerhorn wrote:

> When the hugepages patch was evolving, I suggested that we might want to
> export the "populated map" to applications so that they could ask to
> bind to or interleave across only populated nodes.  We never pursued
> that.  Maybe just eliminate nodes that are unpopulated in the "policy
> zone" from the node masks for MPOL_BIND and MPOL_INTERLEAVE in the
> system calls?  Saves checking the populated node set in the allocation
> paths.  Would need appropriate error return if this resulted in empty
> nodemask.

That would work for the MPOL_BIND case since it has a zonelist. However, 
MPOL_INTERLEAVE does not have a zonelist. I think we need the populated 
map for interleave. The hacky way in how I checked for an unpopulated 
node in the patch just posted is not that effective.

> Of course, memory hotplug could result in nodes becoming empty after the
> nodemasks are adjusted, so we probably can't avoid checks in the
> allocation paths if we want to avoid the bind and interleave issues you
> mention above.

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
