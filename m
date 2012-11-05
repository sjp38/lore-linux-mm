Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 18D746B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 16:52:04 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4616014pbb.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 13:52:03 -0800 (PST)
Date: Mon, 5 Nov 2012 13:52:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: CK5 [03/18] create common functions for boot slab creation
In-Reply-To: <0000013ad1242d03-3810e49c-bad4-44b1-88bf-285da511a400-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1211051350140.5296@chino.kir.corp.google.com>
References: <20121101214538.971500204@linux.com> <0000013abdf1353a-ae01273f-2188-478e-b0c1-b4bdbbaa2652-000000@email.amazonses.com> <alpine.DEB.2.00.1211021333030.5902@chino.kir.corp.google.com>
 <0000013ad1242d03-3810e49c-bad4-44b1-88bf-285da511a400-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

On Mon, 5 Nov 2012, Christoph Lameter wrote:

> > Eek, the calls to __kmem_cache_create() in the boot path as it sits in
> > slab/next right now are ignoring SLAB_PANIC.
> 
> Any failure to create a slab cache during early boot is fatal and we panic
> unconditionally. Like before as far as I can tell but without the use of
> SLAB_PANIC.
> 

With your patch, yeah, but right now mm/slab.c calls directly into 
__kmem_cache_create() with SLAB_PANIC which never gets respected during 
bootstrap since it is handled in kmem_cache_create() in slab/next.  So 
this patch could actually be marketed as a bugfix :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
