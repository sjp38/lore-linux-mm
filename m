Subject: Re: [patch] mmap-speedup-2.5.42-C3
From: Arjan van de Ven <arjanv@fenrus.demon.nl>
In-Reply-To: <Pine.LNX.4.44.0210160751260.2181-100000@home.transmeta.com>
References: <Pine.LNX.4.44.0210160751260.2181-100000@home.transmeta.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-g/FcdP7qi83qpTQR7C1Z"
Date: 16 Oct 2002 17:49:03 +0200
Message-Id: <1034783351.4287.2.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, NPT library mailing list <phil-list@redhat.com>, Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-g/FcdP7qi83qpTQR7C1Z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2002-10-16 at 16:52, Linus Torvalds wrote:
\
> > i think it should be unrelated to the mmap patch. In any case, Andrew
> > added the mmap-speedup patch to 2.5.43-mm1, so we'll hear about this
> > pretty soon.
>=20
> There's at least one Oops-report on linux-kernel on 2.5.43-mm1, where the=
=20
> oops traceback was somewhere in munmap().=20
>=20
> Sounds like there are bugs there.

could be the shared pagetable stuff just as well ;(


--=-g/FcdP7qi83qpTQR7C1Z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9rYpvxULwo51rQBIRAmf5AJ44o4IYxJ/0f5WdIYigLBfVYRjU9ACeKdlR
716BgGis7oE5U8atefdMmIg=
=JiNr
-----END PGP SIGNATURE-----

--=-g/FcdP7qi83qpTQR7C1Z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
