Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id DE52D6B005D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 16:34:45 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2955826pbb.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 13:34:45 -0700 (PDT)
Date: Fri, 2 Nov 2012 13:34:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: CK5 [03/18] create common functions for boot slab creation
In-Reply-To: <0000013abdf1353a-ae01273f-2188-478e-b0c1-b4bdbbaa2652-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1211021333030.5902@chino.kir.corp.google.com>
References: <20121101214538.971500204@linux.com> <0000013abdf1353a-ae01273f-2188-478e-b0c1-b4bdbbaa2652-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

On Thu, 1 Nov 2012, Christoph Lameter wrote:

> Use a special function to create kmalloc caches and use that function in
> SLAB and SLUB.
> 
> V1->V2:
> 	Do check for slasb state in slub's __kmem_cache_create to avoid
> 	unlocking a lock that was not taken
> V2->V3:
> 	Remove slab_state check from sysfs_slab_add(). [Joonsoo]
> 
> V3->V4:
> 	- Use %zd instead of %td for size info.
> 	- Do not add slab caches to the list of slab caches during early
> 	  boot.
> 
> Acked-by: Joonsoo Kim <js1304@gmail.com>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

Eek, the calls to __kmem_cache_create() in the boot path as it sits in 
slab/next right now are ignoring SLAB_PANIC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
