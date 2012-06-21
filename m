Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id BDB546B0087
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 04:01:23 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2259707pbb.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 01:01:22 -0700 (PDT)
Date: Thu, 21 Jun 2012 01:01:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] slab: move FULL state transition to an initcall
In-Reply-To: <1340225959-1966-4-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1206210100260.31077@chino.kir.corp.google.com>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 21 Jun 2012, Glauber Costa wrote:

> During kmem_cache_init_late(), we transition to the LATE state,
> and after some more work, to the FULL state, its last state
> 
> This is quite different from slub, that will only transition to
> its last state (previously SYSFS), in a (late)initcall, after a lot
> more of the kernel is ready.
> 
> This means that in slab, we have no way to taking actions dependent
> on the initialization of other pieces of the kernel that are supposed
> to start way after kmem_init_late(), such as cgroups initialization.
> 
> To achieve more consistency in this behavior, that patch only
> transitions to the UP state in kmem_init_late. In my analysis,
> setup_cpu_cache() should be happy to test for >= UP, instead of
> == FULL. It also has passed some tests I've made.
> 
> We then only mark FULL state after the reap timers are in place,
> meaning that no further setup is expected.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

 [ Might want to fix your address book in your email client because 
   Christoph's name is misspelled in the cc list. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
