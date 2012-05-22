Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 407126B00E7
	for <linux-mm@kvack.org>; Tue, 22 May 2012 11:08:01 -0400 (EDT)
Received: by ggm4 with SMTP id 4so7865516ggm.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 08:08:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161929.264565121@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161929.264565121@linux.com>
Date: Wed, 23 May 2012 00:08:00 +0900
Message-ID: <CAAmzW4PuHiNf2FhyOhNUXvJRF+y2JBdO_92Mqo6LHWKVu8W47g@mail.gmail.com>
Subject: Re: [RFC] Common code 04/12] slabs: Extract common code for kmem_cache_create
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

2012/5/19 Christoph Lameter <cl@linux.com>:
> This patch has the effect of adding sanity checks for SLUB and SLOB
> under CONFIG_DEBUG_VM and removes the checks in SLAB for !CONFIG_DEBUG_VM=
.

If !CONFIG_DEBUG_VM,
code for sanity checks remain in __kmem_cache_create in slab.c, doesn't it?

> +#ifdef CONFIG_DEBUG_VM
> + =A0 =A0 =A0 if (!name || in_interrupt() || size < sizeof(void *) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size > KMALLOC_MAX_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "kmem_cache_create(%s) inte=
grity check"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " failed\n", name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +#endif

Currently, when !CONFIG_DEBUG_VM, name check is handled differently in
sl[aou]bs.
slob worked with !name, but slab, slub return NULL.
So I think some change is needed for name handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
