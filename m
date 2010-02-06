Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E1DEA6B0071
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 02:26:41 -0500 (EST)
Date: Sat, 6 Feb 2010 08:26:36 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [2/4] SLAB: Set up the l3 lists for the memory of freshly added memory
Message-ID: <20100206072636.GO29555@one.firstfloor.org>
References: <201002031039.710275915@firstfloor.org> <20100203213913.D5CD4B1620@basil.firstfloor.org> <alpine.DEB.2.00.1002051316300.2376@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002051316300.2376@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 05, 2010 at 01:17:56PM -0800, David Rientjes wrote:
> > +static int slab_memory_callback(struct notifier_block *self,
> > +				unsigned long action, void *arg)
> > +{
> > +	struct memory_notify *mn = (struct memory_notify *)arg;
> 
> No cast necessary.

It's standard practice to cast void *.

> >  void __init kmem_cache_init_late(void)
> >  {
> >  	struct kmem_cache *cachep;
> > @@ -1583,6 +1598,8 @@ void __init kmem_cache_init_late(void)
> >  	 */
> >  	register_cpu_notifier(&cpucache_notifier);
> >  
> > +	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
> 
> Only needed for CONFIG_NUMA.

Ok.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
