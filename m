From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Fri, 7 Mar 2008 13:20:55 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com> <47D06F07.4070404@cs.helsinki.fi>
In-Reply-To: <47D06F07.4070404@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart15278515.SKMshGgUpO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803071320.58439.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart15278515.SKMshGgUpO
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 06 March 2008, Pekka Enberg wrote:
> Christoph Lameter wrote:
> > Ahh.. That looks like an alignment problem. The other options all add=20
> > data to the object and thus misalign them if no alignment is=20
> > specified.
>=20
> And causes buffer overrun? So the crazy preempt count 0x00056ef8 could a=
=20
> the lower part of an instruction pointer tracked by SLAB_STORE_USER? So=20
> does:
>=20
>    gdb vmlinux
>    (gdb) l *c000000000056ef8
>=20
> translate into any meaningful kernel function?

No, it is in the middle of copy_process. But I will try to identify what
we are actually looking at instead of prempt_count.

Gru=DF,
	Jens

--nextPart15278515.SKMshGgUpO
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0TMqP1aZ9bkt7XMRAl0gAKCY26uf524YiqHEzMX/K4j208k3fQCfdRH2
FOOhdK200tRffjgC4nehT4A=
=QaZ2
-----END PGP SIGNATURE-----

--nextPart15278515.SKMshGgUpO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
