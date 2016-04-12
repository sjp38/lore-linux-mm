Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 88E156B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 14:13:53 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id j35so23144658qge.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:13:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a4si25407428qga.6.2016.04.12.11.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 11:13:52 -0700 (PDT)
Message-ID: <1460484828.7134.4.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Ideas for SLUB allocator
From: Rik van Riel <riel@redhat.com>
Date: Tue, 12 Apr 2016 14:13:48 -0400
In-Reply-To: <alpine.DEB.2.20.1604121057490.14315@east.gentwo.org>
References: <20160412120215.000283c7@redhat.com>
	 <alpine.DEB.2.20.1604121057490.14315@east.gentwo.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Nsgc35t3Flj6nAMjns6c"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <jbrouer@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, js1304@gmail.com, lsf-pc@lists.linux-foundation.org


--=-Nsgc35t3Flj6nAMjns6c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-04-12 at 11:01 -0500, Christoph Lameter wrote:
> On Tue, 12 Apr 2016, Jesper Dangaard Brouer wrote:
>=20
> > I have some ideas for improving SLUB allocator further, after my
> > work
> > on implementing the slab bulk APIs.=C2=A0=C2=A0Maybe you can give me a =
small
> > slot, I only have 7 guidance slides.=C2=A0=C2=A0Or else I hope we/I can=
 talk
> > about these ideas in a hallway track with Christoph and others
> > involved
> > in slab development...
>=20
> I will be there.
>=20
> > I've already published the preliminary slides here:
> > =C2=A0http://people.netfilter.org/hawk/presentations/MM-summit2016/slab=
_
> > mm_summit2016.odp
>=20
> Re Autotuning: SLUB obj per page:
> 	SLUB can combine pages of different orders in a slab cache so
> this would
> 	be possible.
>=20
> per CPU freelist per page:
> 	Could we drop the per cpu partial lists if this works?
>=20
> Clearing memory:
> 	Could exploit the fact that the page is zero on alloc and also
> zap
> 	when no object in the page is in use?

Between the SLUB things both of you want to
discuss, do you think one 30 minute slot will
be enough to start with, or should we schedule
a whole hour?

We have some free slots left on the second day,
where discussions can overflow if necessary.

--=20
All rights reversed

--=-Nsgc35t3Flj6nAMjns6c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJXDTrdAAoJEM553pKExN6Den8H/3fhk4JithGqhJr9atIlw6FW
KUux8bwgePE37BTaflnPVk4t8nHBEwcOmf41De5VlAic37Oo7dWnkoRsebLWIojz
y9GBoCeSAsn/4IpgBAXCkcLp+rGoPvT2XBXDI8QmN3D80Od79dUdSSHng3xxix8X
JczqimYVqtumsXmC/+Z8S0QJblK5ZbzkFoeXbjXz3FJumZcssh49cZgWlzOgHt0g
50QCu2+AS0cMb7zavWqxM1P65szW6SvvQebrxGtTaW82qlzhKhT99xAMl4YTdV7X
7uftQHXSea+Hq5myi+ZYwGThOwyfURWTzc0M9msJRssNcXMZU3r/YhV5yI8iASw=
=bp3c
-----END PGP SIGNATURE-----

--=-Nsgc35t3Flj6nAMjns6c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
