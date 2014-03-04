Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id A2C9E6B004D
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 18:28:05 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ma3so225878pbc.13
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 15:28:05 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id h3si361466paw.149.2014.03.04.15.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Mar 2014 15:28:04 -0800 (PST)
Date: Wed, 5 Mar 2014 10:27:55 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 1/1] mm: use macros from compiler.h instead of
 __attribute__((...))
Message-Id: <20140305102755.6e44b7e1e6eb62f01c41c018@canb.auug.org.au>
In-Reply-To: <20140304132604.5be1b967068f8e03820d2169@linux-foundation.org>
References: <1393767598-15954-1-git-send-email-gidisrael@gmail.com>
	<1393767598-15954-2-git-send-email-gidisrael@gmail.com>
	<20140304132604.5be1b967068f8e03820d2169@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__5_Mar_2014_10_27_55_+1100_4Tkb.4C=j8HwzHJy"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gideon Israel Dsouza <gidisrael@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, geert@linux-m68k.org

--Signature=_Wed__5_Mar_2014_10_27_55_+1100_4Tkb.4C=j8HwzHJy
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Tue, 4 Mar 2014 13:26:04 -0800 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> On Sun,  2 Mar 2014 19:09:58 +0530 Gideon Israel Dsouza <gidisrael@gmail.=
com> wrote:
>=20
> > To increase compiler portability there is <linux/compiler.h> which
> > provides convenience macros for various gcc constructs.  Eg: __weak
> > for __attribute__((weak)).  I've replaced all instances of gcc
> > attributes with the right macro in the memory management
> > (/mm) subsystem.
> >=20
> > ...
> >
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -13,6 +13,7 @@
> >  #include <linux/nodemask.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/mempolicy.h>
> > +#include <linux/compiler.h>
>=20
> It may be overdoing things a bit to explicitly include compiler.h.=20
> It's hard to conceive of any .c file which doesn't already include it.

Stick to Rule 1 :-)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__5_Mar_2014_10_27_55_+1100_4Tkb.4C=j8HwzHJy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTFmGAAAoJEMDTa8Ir7ZwVJnMP/2u/zWMM1eDdxqZfXYTRlPan
tyZ1EGR1tD8WdEQw5N5hOYp4sIIxC6ALo+XFcrNhUJ3fg3/rIqhRAf+5sDWI5MHR
8bkM2Ah5rCmLDTfwUjtjwYgvHHZcBu5Ipk/vtuiRRhPOfr08eTkVBSROGUIw6vkE
Wgn/YN3cIuBa2HhATzqmdRxS5gD91o2m4P4ES4+Vyqeuw2cvB0B0HfEWttRI7CHK
0Qwfy4TTE+DkhzWzdXtUpPD741xJyACUP2EFQFCExHO+3D647P3ldA3QTpnhKSnD
7YJAiJXIDOp4WDPsSHq245Gfti8vhh52WCMDO1FSxj9kyveLC/uxi+RA90azpc5v
0q/ZIelPRMgyMyc03EpFxXe8iDokvtLEYy69v/KX9f+a1I515jYiO13hdKUv2Zo7
feQzCwkp8yQEtdiMcJDzYnkAJtBk5SoFo7FfzLn6eppq7usUp21PnE08gy0920ec
XG3X2+fK9um1w8Je98kRQHosC3kmsA0J51CCwMgOjFMQojVzWaTaZjtl5MYLOQuE
y3sZqQ0zFsvaoYtcW5tHvYgbiJNkUisOcMQ6EVU2qgEB66nzgq4P9hFYwk27WkcT
Guaj1wDzYHCXoOz8VSZpSGZ7ENkqAMFsqrZdnj4PG54n/Ys0YdR3HxFLvRz4KzQG
RdY+Nz/oVRsWmxTDMGSl
=f2hV
-----END PGP SIGNATURE-----

--Signature=_Wed__5_Mar_2014_10_27_55_+1100_4Tkb.4C=j8HwzHJy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
