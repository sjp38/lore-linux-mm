Date: Fri, 27 Oct 2000 21:48:16 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: Discussion on my OOM killer API
Message-ID: <20001027214816.C4324@goop.org>
References: <20001027221259.C0ED4F42C@agnes.fremen.dune> <Pine.LNX.4.10.10010272309040.17292-100000@dax.joh.cam.ac.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010272309040.17292-100000@dax.joh.cam.ac.uk>; from jas88@cam.ac.uk on Fri, Oct 27, 2000 at 11:11:11PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Sutherland <jas88@cam.ac.uk>
Cc: jfm2@club-internet.fr, ingo.oeser@informatik.tu-chemnitz.de, riel@conectiva.com.br, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 27, 2000 at 11:11:11PM +0100, James Sutherland wrote:
> Ehm... nope. mlockall().

Better make sure it's statically linked...  don't want every random library
locked down in their entirety just because the oom killer is using it.

	J

--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.2 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAjn6WpAACgkQf6p1nWJ6IgIZCQCffkep3ImqcWUSWNs8R6sbU+ZJ
uFgAn1qRnNM4ViqjisOpSbJTRI6WVfP0
=aVVM
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
