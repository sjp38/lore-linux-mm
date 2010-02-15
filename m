Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA626B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 16:47:37 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o1FLlYIZ028310
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 13:47:34 -0800
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by kpbe20.cbf.corp.google.com with ESMTP id o1FLlWQC031415
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 13:47:32 -0800
Received: by pxi12 with SMTP id 12so3571747pxi.33
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 13:47:32 -0800 (PST)
Date: Mon, 15 Feb 2010 13:47:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [3/4] SLAB: Set up the l3 lists for the memory of freshly
 added memory v2
In-Reply-To: <20100215060655.GH5723@laptop>
Message-ID: <alpine.DEB.2.00.1002151344020.26927@chino.kir.corp.google.com>
References: <20100211953.850854588@firstfloor.org> <20100211205403.05A8EB1978@basil.firstfloor.org> <alpine.DEB.2.00.1002111344130.8809@chino.kir.corp.google.com> <20100215060655.GH5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010, Nick Piggin wrote:

> > > @@ -1577,6 +1595,8 @@ void __init kmem_cache_init_late(void)
> > >  	 */
> > >  	register_cpu_notifier(&cpucache_notifier);
> > >  
> > > +	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
> > > +
> > 
> > Only needed for CONFIG_NUMA, but there's no side-effects for UMA kernels 
> > since status_change_nid will always be -1.
> 
> Compiler doesn't know that, though.
> 

Right, setting up a memory hotplug callback for UMA kernels here isn't 
necessary although slab_node_prepare() would have to be defined 
unconditionally.  I made this suggestion in my review of the patchset's 
initial version but it was left unchanged, so I'd rather see it included 
than otherwise stall out.  This could always be enclosed in
#ifdef CONFIG_NUMA later just like the callback in slub does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
