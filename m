From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Fri, 7 Mar 2008 23:09:16 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <200803062307.22436.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4003371.dXf8GQBHZs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803072309.19788.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart4003371.dXf8GQBHZs
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


> Ahh.. That looks like an alignment problem. The other options all add=20
> data to the object and thus misalign them if no alignment is=20
> specified.
>=20
> Seems that powerpc expect an alignment but does not specify it for some d=
ata.
>=20
> You can restrict the debug for certain slabs only. Try some of the arch=20
> specific slab caches first.

I started with rtas_flash_cache, hugepte_cache, spufs_inode_cache, pgd_cach=
e,
pmd_cache and around 20 other that are allocated beforce the crash with no
success yet.

Gru=DF,
	Jens

--nextPart4003371.dXf8GQBHZs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0b0PP1aZ9bkt7XMRAmyzAJ95PGm2q7NrYWLhU1CZ2VL4QbgCqACg2VsI
zzcNr+IDYmD18kG6TQglOJw=
=oqdk
-----END PGP SIGNATURE-----

--nextPart4003371.dXf8GQBHZs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
