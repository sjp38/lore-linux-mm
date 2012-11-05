Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 33B856B002B
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 10:15:41 -0500 (EST)
Date: Mon, 5 Nov 2012 15:15:39 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK5 [03/18] create common functions for boot slab creation
In-Reply-To: <alpine.DEB.2.00.1211021333030.5902@chino.kir.corp.google.com>
Message-ID: <0000013ad1242d03-3810e49c-bad4-44b1-88bf-285da511a400-000000@email.amazonses.com>
References: <20121101214538.971500204@linux.com> <0000013abdf1353a-ae01273f-2188-478e-b0c1-b4bdbbaa2652-000000@email.amazonses.com> <alpine.DEB.2.00.1211021333030.5902@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

On Fri, 2 Nov 2012, David Rientjes wrote:

> Eek, the calls to __kmem_cache_create() in the boot path as it sits in
> slab/next right now are ignoring SLAB_PANIC.

Any failure to create a slab cache during early boot is fatal and we panic
unconditionally. Like before as far as I can tell but without the use of
SLAB_PANIC.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
