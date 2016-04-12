Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B82626B025F
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 09:37:31 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id e128so14068860pfe.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:37:31 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q75si10039136pfq.207.2016.04.12.06.37.30
        for <linux-mm@kvack.org>;
        Tue, 12 Apr 2016 06:37:31 -0700 (PDT)
Date: Tue, 12 Apr 2016 09:37:28 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Ideas for SLUB allocator
Message-ID: <20160412133728.GM2781@linux.intel.com>
References: <20160412120215.000283c7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160412120215.000283c7@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, js1304@gmail.com, lsf-pc@lists.linux-foundation.org

On Tue, Apr 12, 2016 at 12:02:15PM +0200, Jesper Dangaard Brouer wrote:
> Hi Rik,
> 
> I have another topic, which is very MM-specific.
> 
> I have some ideas for improving SLUB allocator further, after my work
> on implementing the slab bulk APIs.  Maybe you can give me a small
> slot, I only have 7 guidance slides.  Or else I hope we/I can talk
> about these ideas in a hallway track with Christoph and others involved
> in slab development...
> 
> I've already published the preliminary slides here:
>  http://people.netfilter.org/hawk/presentations/MM-summit2016/slab_mm_summit2016.odp

The current bulk API returns the pointers in an array.  What the
radix tree would like is the ability to bulk allocate from a slab and
chain the allocations through an offset.  See __radix_tree_preload()
in lib/radix-tree.c.  I don't know if this is a common thing to do
elsewhere in the kernel.  Obviously, radix-tree could allocate the array
on the stack and set up the chain itself, but I would think it would be
just as easy for slab to do it itself and save the stack space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
