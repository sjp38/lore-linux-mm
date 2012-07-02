Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id BEB3B6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 06:57:17 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so9554802lbj.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 03:57:15 -0700 (PDT)
Date: Mon, 2 Jul 2012 13:57:12 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 3/4] slab: move FULL state transition to an initcall
In-Reply-To: <alpine.DEB.2.00.1206210100260.31077@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1207021357050.1916@tux.localdomain>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-4-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206210100260.31077@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 21 Jun 2012, David Rientjes wrote:
> > During kmem_cache_init_late(), we transition to the LATE state,
> > and after some more work, to the FULL state, its last state
> > 
> > This is quite different from slub, that will only transition to
> > its last state (previously SYSFS), in a (late)initcall, after a lot
> > more of the kernel is ready.
> > 
> > This means that in slab, we have no way to taking actions dependent
> > on the initialization of other pieces of the kernel that are supposed
> > to start way after kmem_init_late(), such as cgroups initialization.
> > 
> > To achieve more consistency in this behavior, that patch only
> > transitions to the UP state in kmem_init_late. In my analysis,
> > setup_cpu_cache() should be happy to test for >= UP, instead of
> > == FULL. It also has passed some tests I've made.
> > 
> > We then only mark FULL state after the reap timers are in place,
> > meaning that no further setup is expected.
> > 
> > Signed-off-by: Glauber Costa <glommer@parallels.com>
> > Acked-by: Christoph Lameter <cl@linux.com>
> > CC: Pekka Enberg <penberg@cs.helsinki.fi>
> > CC: David Rientjes <rientjes@google.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
>  [ Might want to fix your address book in your email client because 
>    Christoph's name is misspelled in the cc list. ]

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
