Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6476B004A
	for <linux-mm@kvack.org>; Sat, 23 Jul 2011 07:22:18 -0400 (EDT)
Date: Sat, 23 Jul 2011 13:22:07 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
Message-ID: <20110723112207.GA2355@breakpoint.cc>
References: <20110716211850.GA23917@breakpoint.cc>
 <alpine.LFD.2.02.1107172333340.2702@ionos>
 <alpine.DEB.2.00.1107201619540.3528@tiger>
 <1311168638.5345.80.camel@twins>
 <alpine.DEB.2.00.1107201642500.4921@tiger>
 <1311176680.29152.20.camel@twins>
 <20110721071459.GA2961@breakpoint.cc>
 <1311341165.27400.58.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311341165.27400.58.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

* Thus spake Peter Zijlstra (peterz@infradead.org):
> Thanks!
You're welcome.

> > +static void slab_each_set_lock_classes(struct kmem_cache *cachep)
> > +{
> > +	int node;
> > +
> > +	for_each_online_node(node) {
> > +		slab_set_lock_classes(cachep, &debugobj_l3_key,
> > +				&debugobj_alc_key, node);
> > +	}
> > +}
> 
> Hmm, O(nr_nodes^2), sounds about right for alien crap, right?
A little less if not all nodes are online :) However it is the same kind of
init used earlier by setup_cpu_cache().
I tried to pull lockclass into cachep but lockdep didn't like this.

> Still needs some hotplug love though, maybe something like the below...
> Sebastian, would you be willing to give the thing another spin to see if
> I didnt (again) break anything silly?
Looks good, compiles and seems to work :)

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
