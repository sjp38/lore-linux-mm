Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EC6316B0010
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 23:23:51 -0400 (EDT)
Subject: Re: [patch] thp: fix khugepaged defrag tunable documentation
From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 15 Sep 2011 04:23:26 +0100
In-Reply-To: <alpine.DEB.2.00.1109141910560.12561@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1109141910560.12561@chino.kir.corp.google.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gzOaz298l2wwP5ktUmmY"
Message-ID: <1316057014.14749.71.camel@deadeye>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org


--=-gzOaz298l2wwP5ktUmmY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-09-14 at 19:12 -0700, David Rientjes wrote:
> e27e6151b154 ("mm/thp: use conventional format for boolean attributes")
> changed /sys/kernel/mm/transparent_hugepage/khugepaged/defrag to be tuned
> by using 1 (enabled) or 0 (disabled) instead of "yes" and "no",
> respectively.
>=20
> Update the documentation.
[...]

Oops, sorry I missed this.

Ben.

--=20
Ben Hutchings
All extremists should be taken out and shot.

--=-gzOaz298l2wwP5ktUmmY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATnFvrue/yOyVhhEJAQqqOw/5AX6GkpAFJHoc8Gp6FUDHrKCVDPo0E5A0
H43E+VEb0++80JBoG9CiNB1XlWkNaCLwVvGn13eOXcFfDAZ/IuBSPE9zH0+1JVnb
46sWGs/ZG4tjeHZguUeU/wuRwwZu+JRR9IYDZkKSdPC0MYd+DSECmnaJJxE9tKUa
B+GghCdN50zMCfMArTDJyRTjZGIeBVoRgwgoR69vrNr+0QBazvdBzLhpYtd/1y7d
i66fI1O4ba7ycxMoT97gRIVPcNHQl5OcW8LRT2dtEY0knL9ieH/2nCgUAgsW6NjB
CWrUIuGJjT/5Ge/rim8Qa2i2MXXZLx/XtyjoVVtg//G6/xANoIV8jXxSSVcpky54
0q5xGA47IWVey3Z43pnlJcQpU0Q3h13RpGI1qWn6VQQW41oy6oxiDjmfCfekO6u6
q62URNNIebkAGQYwby0H7vSRDCP7vNgEr5f1qd5GadWDWeCOrT4I2Xf1XmejisaI
6KJXoyELA07vfERFnLBXvsNg0lAgn3L9Q5AFHZ6T9HjO3zOQP1XdD2c3Q1BvZaXs
YTu1ciokwsaTYcX6ZY9GQ9U2inSfk+4idWHjOxdjOeyBUC9ObVzld2juBK6zV2jn
PtgdaSfytKijV9C3Bg0yC78rs51/qfO5weJwdvybJnbd64k3HpER1p8944MFKBCJ
pmsGPL+otSU=
=uE4Y
-----END PGP SIGNATURE-----

--=-gzOaz298l2wwP5ktUmmY--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
