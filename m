Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id DFF406B0071
	for <linux-mm@kvack.org>; Wed, 30 May 2012 11:29:35 -0400 (EDT)
Date: Wed, 30 May 2012 10:29:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common 06/22] Extract common fields from struct kmem_cache
In-Reply-To: <CAOJsxLGHZjucZUi=K3V6QDgP-UqA2GQY=z7D8poKMTO-JETZ2g@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205301028330.28968@router.home>
References: <20120523203433.340661918@linux.com> <20120523203508.434967564@linux.com> <CAOJsxLGHZjucZUi=K3V6QDgP-UqA2GQY=z7D8poKMTO-JETZ2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-774467634-1338391774=:28968"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-774467634-1338391774=:28968
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 30 May 2012, Pekka Enberg wrote:

> > =A0/*
> > + * Common fields provided in kmem_cache by all slab allocators
> > + */
> > +#define SLAB_COMMON \
> > + =A0 =A0 =A0 unsigned int size, align; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> > + =A0 =A0 =A0 unsigned long flags; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> > + =A0 =A0 =A0 const char *name; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> > + =A0 =A0 =A0 int refcount; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> > + =A0 =A0 =A0 void (*ctor)(void *); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> > + =A0 =A0 =A0 struct list_head list;
> > +
>
> I don't like this at all - it obscures the actual "kmem_cache"
> structures. If we can't come up with a reasonable solution that makes
> this a proper struct that's embedded in allocator-specific
> "kmem_cache" structures, it's best that we rename the fields but keep
> them inlined and drop this macro..

Actually that is a good idea. We can keep a fake struct in comments around
in slab.h to document what all slab allocators have to support and then at
some point we may be able to integrate the struct.

---1463811839-774467634-1338391774=:28968--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
