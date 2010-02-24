Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A0C496B0093
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 20:47:13 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o1O1lAmF005059
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:47:11 -0800
Received: from fxm5 (fxm5.prod.google.com [10.184.13.5])
	by spaceape23.eur.corp.google.com with ESMTP id o1O1l9Gt003589
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:47:09 -0800
Received: by fxm5 with SMTP id 5so4490364fxm.9
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:47:09 -0800 (PST)
Date: Tue, 23 Feb 2010 17:47:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: way to allocate memory within a range ?
In-Reply-To: <17cb70ee1002231646m508f6483mcb667d4e67d9807f@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1002231744110.3435@chino.kir.corp.google.com>
References: <17cb70ee1002231646m508f6483mcb667d4e67d9807f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Auguste Mome <augustmome@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Feb 2010, Auguste Mome wrote:

> I'd like to use kmem_cache() system, but need the memory taken from a
> specific range if requested, outside the range otherwise.
> I think about adding new zone and define new GFP flag to either select or
> ignore the zone. Does it sound possible? Then I welcome any hint if you know
> where to add the appropriated test in allocator, how to attach the
> region to the new zone id).
> 
> Or slab/slub system is not designed for this, I should forget it and
> opt for another system?
> 

No slab allocator is going to be designed for that other than SLAB_DMA to 
allocate from lowmem.  If you don't have need for lowmem, why do you need 
memory only from a certain range?  I can imagine it would have a usecase 
for memory hotplug to avoid allocating slab that cannot be reclaimed on 
certain nodes, but ZONE_MOVABLE seems more appropriate to guarantee such 
migration properties.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
