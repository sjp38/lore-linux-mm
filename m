Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A19FA6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 13:49:50 -0400 (EDT)
Date: Tue, 22 May 2012 12:49:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 04/12] slabs: Extract common code for
 kmem_cache_create
In-Reply-To: <CAAmzW4PuHiNf2FhyOhNUXvJRF+y2JBdO_92Mqo6LHWKVu8W47g@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205221248260.21828@router.home>
References: <20120518161906.207356777@linux.com> <20120518161929.264565121@linux.com> <CAAmzW4PuHiNf2FhyOhNUXvJRF+y2JBdO_92Mqo6LHWKVu8W47g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-876156424-1337708989=:21828"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-876156424-1337708989=:21828
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 23 May 2012, JoonSoo Kim wrote:

> 2012/5/19 Christoph Lameter <cl@linux.com>:
> > This patch has the effect of adding sanity checks for SLUB and SLOB
> > under CONFIG_DEBUG_VM and removes the checks in SLAB for !CONFIG_DEBUG_=
VM.
>
> If !CONFIG_DEBUG_VM,
> code for sanity checks remain in __kmem_cache_create in slab.c, doesn't i=
t?

Some sanity checks remain after this patch and are moved later.

>
> > +#ifdef CONFIG_DEBUG_VM
> > + =A0 =A0 =A0 if (!name || in_interrupt() || size < sizeof(void *) ||
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size > KMALLOC_MAX_SIZE) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "kmem_cache_create(%s) in=
tegrity check"
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " failed\n", name);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> > + =A0 =A0 =A0 }
> > +#endif
>
> Currently, when !CONFIG_DEBUG_VM, name check is handled differently in
> sl[aou]bs.
> slob worked with !name, but slab, slub return NULL.
> So I think some change is needed for name handling.

Right. All should check for !name and fail on that.


---1463811839-876156424-1337708989=:21828--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
