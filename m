From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Fri, 7 Mar 2008 23:18:45 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803071434240.9017@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0803071443430.9202@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0803071443430.9202@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart9018714.WI04nQd1P5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803072318.45291.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart9018714.WI04nQd1P5
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


> And checking whether disabling debugging for the 'task_struct' cache make=
s=20
> the problem go away.

No, unfortunately it doesnt.

Gru=DF,
	Jens

--nextPart9018714.WI04nQd1P5
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0b9FP1aZ9bkt7XMRAglCAKDJuSPQXG2uxEPmaFPpnyN5peJpHgCeJMV2
jafEUEsrHTF5BxOWegngFUo=
=PqAG
-----END PGP SIGNATURE-----

--nextPart9018714.WI04nQd1P5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
