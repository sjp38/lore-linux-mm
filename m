Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id A3E576B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 01:58:35 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id hz20so5710265lab.6
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 22:58:34 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id al1si585487lbc.23.2015.01.22.22.58.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 22:58:33 -0800 (PST)
Received: by mail-lb0-f181.google.com with SMTP id u10so5482499lbd.12
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 22:58:32 -0800 (PST)
From: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Date: Fri, 23 Jan 2015 09:58:34 +0300
Subject: Re: [PATCH] mm/slub: suppress BUG messages for
 kmem_cache_alloc/kmem_cache_free
Message-ID: <20150123065834.GI25900@localhost.localdomain>
References: <1421932519-21036-1-git-send-email-Andrej.Skvortzov@gmail.com>
 <alpine.DEB.2.10.1501221518020.27807@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="AQYPrgrEUc/1pSX1"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1501221518020.27807@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org


--AQYPrgrEUc/1pSX1
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 22, 2015 at 03:19:18PM -0800, David Rientjes wrote:
> On Thu, 22 Jan 2015, Andrey Skvortsov wrote:
>=20
> > diff --git a/mm/slub.c b/mm/slub.c
> > index ceee1d7..6bcd031 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2404,7 +2404,7 @@ redo:
> >  	 */
> >  	do {
> >  		tid =3D this_cpu_read(s->cpu_slab->tid);
> > -		c =3D this_cpu_ptr(s->cpu_slab);
> > +		c =3D raw_cpu_ptr(s->cpu_slab);
> >  	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid !=3D c->tid));
> > =20
> >  	/*
> > @@ -2670,7 +2670,7 @@ redo:
> >  	 */
> >  	do {
> >  		tid =3D this_cpu_read(s->cpu_slab->tid);
> > -		c =3D this_cpu_ptr(s->cpu_slab);
> > +		c =3D raw_cpu_ptr(s->cpu_slab);
> >  	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid !=3D c->tid));
> > =20
> >  	/* Same with comment on barrier() in slab_alloc_node() */
>=20
> This should already be fixed with=20
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-slub-optimize-alloc-free-fast=
path-by-removing-preemption-on-off-v3.patch

> You can find the latest mmotm, which was just released, at=20
> http://ozlabs.org/~akpm/mmotm and it should be in linux-next tomorrow.
ok. I've just looked at linux-next/master and
linux-next/akpm branches and that was not fixed there. Thanks for the
link. I'll look there in the future for mm-related patches posting a
new one.

--=20
Best regards,
Andrey Skvortsov

Secure eMail with gnupg: See http://www.gnupg.org/
PGP Key ID: 0x57A3AEAD

--AQYPrgrEUc/1pSX1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJUwfEaAAoJEAF8y6L1SLCtHtYQAKKwaJbRsFlchx7cK98xaXAR
wH18lsI/BL4+r4kLBEcW7ISP6HN895EXHE64Ie23I+eYV5CKEGxkcxEPyc0p37ma
I47s1nhox3FHhI9+ax8d5z8dX5hmVf6+GXdLxauxpEYptDn/rO9KppBoPZ5ixD7E
OaPuggO9ApDSzTfBn7FbLEOfGSxSyYoYedzXsr54jMf9IzqAZpHCzTtEofBynbQv
5DEM1IhR0HkdyqbtbhBozbNbEnuU3WwUH4iD0eRyLc1YXX1yVHlIIvB4Nj6v0ci6
Hm7VJcWGWQBC0X8IEOXMElanIRuK8irJoPt8AJmCXVJryZX+MnBZHxxJsKevJE7p
OAMWmEf/S+JpypfgV8N/MTN604ZEzFISjr/cbmrBEt9vXcxyjWjbMZ984h+pkf7C
jEqTuFS1SZydBHV8DJluXl3TJWxBk8sJKM5IwkvG+eshjZtU/Dw8xhNOfGQb8B90
RYN3/Qu9sHi7Y7TLs7/iPSSdDUDqnIUcE8cSGYC/c6OsHlvYs/V0u6IPKTwaFv5B
eDtIV3qFfDOfcOwTjAOUHQwzA10Vbd4WMFUVUMCjRFkWTnsbq7aDyycuEEMqmkPE
qgLUnPUQ88jPa3aHlWv88Pj4QBZcx0N3XrhvcQvyxpDbqqsZ5JsQDShp9kmN5utf
Z+iUgeqYtJn23+fkb7sU
=TID4
-----END PGP SIGNATURE-----

--AQYPrgrEUc/1pSX1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
