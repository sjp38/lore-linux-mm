Date: Mon, 11 Jun 2007 20:19:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612031718.GP3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706112018260.25631@schroedinger.engr.sgi.com>
References: <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com>
 <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
 <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
 <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
 <20070612023421.GL3798@us.ibm.com> <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com>
 <20070612031718.GP3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> > Ahh did not see that. Can you not call simply into interleave() from 
> > mempolicy.c? It will get you the counter that you need.
> 
> You just told me that mempolicy.c is built conditionally on NUMA.
> alloc_fresh_huge_page() is not, it only depeonds on CONFIG_HUGETLB_PAGE!

Well you just need to have the appropriate fallbacks defined in 
mempolicy.h

> The only interleave functions I see in mempolicy.c are:
> 
> interleave_nodes(), which takes a mempolicy, which I don't have in
> hugetlb.c
> 
> interleave_nid(), which also takes a mempolicy
> 
> I guess I could try and use huge_zonelist(), but I don't see the point?

Export a function for the interleave functionality so that we do not have 
to replicate the same thing in various locations in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
