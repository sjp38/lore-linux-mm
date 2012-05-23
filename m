Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 158D76B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 11:42:23 -0400 (EDT)
Date: Wed, 23 May 2012 10:42:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for
 kmem_cache_destroy
In-Reply-To: <CAAmzW4Oxwq-Gd7ts3F1funk5-fwVOSHEBz2fh5Rno90E8nnG4Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205231042130.30940@router.home>
References: <20120518161906.207356777@linux.com> <20120518161932.147485968@linux.com> <CAAmzW4Oxwq-Gd7ts3F1funk5-fwVOSHEBz2fh5Rno90E8nnG4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-964558924-1337787741=:30940"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-964558924-1337787741=:30940
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 24 May 2012, JoonSoo Kim wrote:

> > +void __kmem_cache_destroy(struct kmem_cache *s)
> > +{
> > + =A0 =A0 =A0 kfree(s);
> > + =A0 =A0 =A0 sysfs_slab_remove(s);
> > =A0}
> > -EXPORT_SYMBOL(kmem_cache_destroy);
>
> sysfs_slab_remove(s) -> kfree(s) is correct order.
> If not, it will break the system.

Ok. Changed.

---1463811839-964558924-1337787741=:30940--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
