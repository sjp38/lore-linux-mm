Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 65C3F6B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:22:25 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o6EKMNNt005457
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 13:22:23 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by hpaq2.eem.corp.google.com with ESMTP id o6EKMLnR007190
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 13:22:22 -0700
Received: by pwi10 with SMTP id 10so8055pwi.6
        for <linux-mm@kvack.org>; Wed, 14 Jul 2010 13:22:21 -0700 (PDT)
Date: Wed, 14 Jul 2010 13:22:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
In-Reply-To: <alpine.DEB.2.00.1007132055470.14067@router.home>
Message-ID: <alpine.DEB.2.00.1007141316530.26119@chino.kir.corp.google.com>
References: <20100709190706.938177313@quilx.com> <20100710195621.GA13720@fancy-poultry.org> <alpine.DEB.2.00.1007121010420.14328@router.home> <20100712163900.GA8513@fancy-poultry.org> <alpine.DEB.2.00.1007121156160.18621@router.home> <20100713135650.GA6444@fancy-poultry.org>
 <alpine.DEB.2.00.1007132055470.14067@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Heinz Diehl <htd@fancy-poultry.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010, Christoph Lameter wrote:

> > > Can you get us the config file. What is the value of
> > > PERCPU_DYMAMIC_EARLY_SIZE?
> >
> > My .config file is attached. I don't know how to find out what value
> > PERCPU_DYNAMIC_EARLY_SIZE is actually on, how could I do that? There's
> > no such thing in my .config.
> 
> I dont see anything in there at first glance that would cause slub to
> increase its percpu usage. This is straight upstream?
> 

The problem is that he has CONFIG_NODES_SHIFT=10 and struct kmem_cache has 
an array of struct kmem_cache_node pointers with MAX_NUMNODES entries 
which blows its size up to over 8K.  That's probably overkill for his 
quad-core 8GB AMD, so I'd recommend lowering CONFIG_NODES_SHIFT to 6.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
