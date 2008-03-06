From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Thu, 6 Mar 2008 23:07:22 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061354210.15083@schroedinger.engr.sgi.com> <47D06993.9000703@cs.helsinki.fi>
In-Reply-To: <47D06993.9000703@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1633166.YhnW3jjjv1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803062307.22436.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart1633166.YhnW3jjjv1
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


> You mention slub_debug=3D- makes the problem go away but can you narrow i=
t=20
> down to a specific debug option described in Documentation/vm/slub.txt?=20
> In particular, does disabling slab poisoning or red zoning make the=20
> problem go away also?

I tried with slub_debug=3D F,Z,P and U. Only with F the problem is not ther=
e.

Gru=DF,
	Jens

--nextPart1633166.YhnW3jjjv1
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0GsaP1aZ9bkt7XMRApRvAKCuNyaei+ueMmIAlMUJzAg/+oAjXgCgh4rS
ZfX6rX8MNQYyDTc95jGT41c=
=DmN8
-----END PGP SIGNATURE-----

--nextPart1633166.YhnW3jjjv1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
