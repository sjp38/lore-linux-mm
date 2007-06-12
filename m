Date: Mon, 11 Jun 2007 19:54:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <20070612023209.GJ3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
References: <20070611221036.GA14458@us.ibm.com>
 <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com>
 <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
 <20070612000705.GH14458@us.ibm.com> <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
 <20070612020257.GF3798@us.ibm.com> <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
 <20070612023209.GJ3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> On 11.06.2007 [19:20:58 -0700], Christoph Lameter wrote:
> > On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> > 
> > > [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
> > 
> > There is no point in compiling the interleave logic for !NUMA. There
> > needs to be some sort of !NUMA fallback in hugetlb. It would be better
> > to call a interleave function in mempolicy.c that provides an
> > appropriate shim for !NUMA.
> 
> Hrm, if !NUMA, is the nid of the only node guaranteed to be 0? If so, I
> can just

Yes.

> Make alloc_fresh_huge_page() and other generic variants call into the
> _node() versions with nid=0, if !NUMA.
> 
> Would that be ok?

I am not sure what you are up to. Just make sure that the changes are 
minimal. Look in the source code for other examples on how !NUMA 
situations were handled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
