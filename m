Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D6B9B6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 17:44:55 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o57Liodd003946
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 14:44:52 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by kpbe16.cbf.corp.google.com with ESMTP id o57LilK3027618
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 14:44:49 -0700
Received: by pxi6 with SMTP id 6so1371620pxi.15
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 14:44:47 -0700 (PDT)
Date: Mon, 7 Jun 2010 14:44:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified
 node.
In-Reply-To: <20100521211537.530913777@quilx.com>
Message-ID: <alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100521211537.530913777@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010, Christoph Lameter wrote:

> kmalloc_node() and friends can be passed a constant -1 to indicate
> that no choice was made for the node from which the object needs to
> come.
> 
> Add a constant for this.
> 

I think it would be better to simply use the generic NUMA_NO_NODE for this 
purpose, which is identical to how hugetlb, pxm mappings, etc, use it to 
specify no specific node affinity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
