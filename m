Message-ID: <43B07FE9.4000803@colorfullife.com>
Date: Tue, 27 Dec 2005 00:42:33 +0100
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: NUMA slab -- minor optimizations
References: <20051129085049.GA3573@localhost.localdomain> <20051129085456.GC3573@localhost.localdomain>
In-Reply-To: <20051129085456.GC3573@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, clameter@engr.sgi.com, Alok Kataria <alokk@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

Ravikiran G Thirumalai wrote:

>Patch adds some minor optimizations:
>1. Keeps on chip interrupts enabled for a bit longer while draining cpu
>caches
>2. Calls numa_node_id once in cache_reap
>
>Signed-off-by: Alok N Kataria <alokk@calsoftinc.com>
>Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
>Signed-off-by: Shai Fultheim <shai@scalex86.org>
>
>Index: linux-2.6.15-rc1/mm/slab.c
>===================================================================
>--- linux-2.6.15-rc1.orig/mm/slab.c	2005-11-17 21:32:43.000000000 -0800
>+++ linux-2.6.15-rc1/mm/slab.c	2005-11-17 21:32:50.000000000 -0800
>@@ -1914,18 +1914,18 @@
> 
> 	smp_call_function_all_cpus(do_drain, cachep);
> 	check_irq_on();
>-	spin_lock_irq(&cachep->spinlock);
>+	spin_lock(&cachep->spinlock);
>  
>
Isn't that a bug? What prevents an interrupt from occuring after the 
spin_lock() and then causing a deadlock on cachep->spinlock?

--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
