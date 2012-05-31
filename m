Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D0BB46B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 03:52:35 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so826678lbj.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 00:52:33 -0700 (PDT)
Date: Thu, 31 May 2012 10:52:30 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: Common 06/22] Extract common fields from struct kmem_cache
In-Reply-To: <alpine.DEB.2.00.1205301028330.28968@router.home>
Message-ID: <alpine.LFD.2.02.1205311052090.3944@tux.localdomain>
References: <20120523203433.340661918@linux.com> <20120523203508.434967564@linux.com> <CAOJsxLGHZjucZUi=K3V6QDgP-UqA2GQY=z7D8poKMTO-JETZ2g@mail.gmail.com> <alpine.DEB.2.00.1205301028330.28968@router.home>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-510044906-1338450751=:3944"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-510044906-1338450751=:3944
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 30 May 2012, Christoph Lameter wrote:

> On Wed, 30 May 2012, Pekka Enberg wrote:
> 
> > >  /*
> > > + * Common fields provided in kmem_cache by all slab allocators
> > > + */
> > > +#define SLAB_COMMON \
> > > +       unsigned int size, align;                                       \
> > > +       unsigned long flags;                                            \
> > > +       const char *name;                                               \
> > > +       int refcount;                                                   \
> > > +       void (*ctor)(void *);                                           \
> > > +       struct list_head list;
> > > +
> >
> > I don't like this at all - it obscures the actual "kmem_cache"
> > structures. If we can't come up with a reasonable solution that makes
> > this a proper struct that's embedded in allocator-specific
> > "kmem_cache" structures, it's best that we rename the fields but keep
> > them inlined and drop this macro..
> 
> Actually that is a good idea. We can keep a fake struct in comments around
> in slab.h to document what all slab allocators have to support and then at
> some point we may be able to integrate the struct.

Works for me.

			Pekka
--8323328-510044906-1338450751=:3944--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
