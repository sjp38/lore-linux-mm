Received: (from jmm@localhost)
	by bp6.sublogic.lan (8.9.3/8.9.3) id JAA13992
	for linux-mm@kvack.org; Mon, 17 Jul 2000 09:01:31 -0400
Date: Mon, 17 Jul 2000 09:01:31 -0400
From: James Manning <jmm@computer.org>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
Message-ID: <20000717090131.D10936@bp6.sublogic.lan>
References: <Pine.LNX.4.21.0007111503520.10961-100000@duckman.distro.conectiva> <200007170709.DAA27512@ocelot.cc.gatech.edu> <20000717102811.D5127@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="CblX+4bnyfN0pR09"
In-Reply-To: <20000717102811.D5127@redhat.com>; from sct@redhat.com on Mon, Jul 17, 2000 at 10:28:11AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--CblX+4bnyfN0pR09
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable

[Stephen C. Tweedie]
> > Having said that, LRU is certainly broken, but there are other ways to
> > fix it.
>=20
> Right.  LFU is just one way of fixing LRU.

Just food for thought for anyone wanting to read up on other algorithms
and a decent explanation of the basic problem.

http://www.cs.wisc.edu/~solomon/cs537/paging.html
--=20
James Manning <jmm@computer.org>
GPG Key fingerprint =3D B913 2FBD 14A9 CE18 B2B7  9C8E A0BF B026 EEBB F6E4

--CblX+4bnyfN0pR09
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.1 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE5cwOqoL+wJu679uQRAQ8wAKCSGlMS2tO+DByDpnFzxmVfMIbZbQCdFrwa
4Y4+oT4DPUFFUf5hsUVwtmA=
=ZSf4
-----END PGP SIGNATURE-----

--CblX+4bnyfN0pR09--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
