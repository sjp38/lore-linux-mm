Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5ED5A6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 18:33:38 -0400 (EDT)
Date: Mon, 7 Jun 2010 17:30:10 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified
 node.
In-Reply-To: <alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006071729560.12482@router.home>
References: <20100521211452.659982351@quilx.com> <20100521211537.530913777@quilx.com> <alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jun 2010, David Rientjes wrote:

> On Fri, 21 May 2010, Christoph Lameter wrote:
>
> > kmalloc_node() and friends can be passed a constant -1 to indicate
> > that no choice was made for the node from which the object needs to
> > come.
> >
> > Add a constant for this.
> >
>
> I think it would be better to simply use the generic NUMA_NO_NODE for this
> purpose, which is identical to how hugetlb, pxm mappings, etc, use it to
> specify no specific node affinity.

Ok will do that in the next release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
