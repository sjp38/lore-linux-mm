Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id BF0D86B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:03:08 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so2235028qgf.28
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 08:03:08 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id n7si6852311qas.81.2014.06.19.08.03.07
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 08:03:08 -0700 (PDT)
Date: Thu, 19 Jun 2014 10:03:04 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: slub/debugobjects: lockup when freeing memory
In-Reply-To: <53A2F406.4010109@oracle.com>
Message-ID: <alpine.DEB.2.11.1406191001090.2785@gentwo.org>
References: <53A2F406.4010109@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 19 Jun 2014, Sasha Levin wrote:

> [  690.770137] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [  690.770137] __slab_alloc (mm/slub.c:1732 mm/slub.c:2205 mm/slub.c:2369)
> [  690.770137] ? __lock_acquire (kernel/locking/lockdep.c:3189)
> [  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> [  690.770137] kmem_cache_alloc (mm/slub.c:2442 mm/slub.c:2484 mm/slub.c:2489)
> [  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> [  690.770137] ? debug_object_activate (lib/debugobjects.c:439)
> [  690.770137] __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> [  690.770137] debug_object_init (lib/debugobjects.c:365)
> [  690.770137] rcuhead_fixup_activate (kernel/rcu/update.c:231)
> [  690.770137] debug_object_activate (lib/debugobjects.c:280 lib/debugobjects.c:439)
> [  690.770137] ? discard_slab (mm/slub.c:1486)
> [  690.770137] __call_rcu (kernel/rcu/rcu.h:76 (discriminator 2) kernel/rcu/tree.c:2585 (discriminator 2))

__call_rcu does a slab allocation? This means __call_rcu can no longer be
used in slab allocators? What happened?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
