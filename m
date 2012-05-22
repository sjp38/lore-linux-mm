Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 1F9CB6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 11:44:56 -0400 (EDT)
Received: by yenm7 with SMTP id m7so7930393yen.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 08:44:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161930.398418977@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161930.398418977@linux.com>
Date: Wed, 23 May 2012 00:44:55 +0900
Message-ID: <CAAmzW4NUKsij1zkGWJwOX7DmWcfFZuWyMOLHyYp6vsvbmu-g0w@mail.gmail.com>
Subject: Re: [RFC] Common code 06/12] slabs: Use a common mutex definition
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

2012/5/19 Christoph Lameter <cl@linux.com>:
> Use the mutex definition from SLAB and make it the common way to take a sleeping lock.
>
> This has the effect of using a mutex instead of a rw semaphore for SLUB.
>
> SLOB gains the use of a mutex for kmem_cache_create serialization.
> Not needed now but SLOB may acquire some more features later (like slabinfo
> / sysfs support) through the expansion of the common code that will
> need this.
>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
