Subject: Re: [PATCH] token based thrashing control
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20040801040553.305f0275.akpm@osdl.org>
References: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
	 <20040801040553.305f0275.akpm@osdl.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-drP37/Ab+2BiGsw4j7nc"
Message-Id: <1091358809.2816.7.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Sun, 01 Aug 2004 13:13:29 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, sjiang@cs.wm.edu
List-ID: <linux-mm.kvack.org>

--=-drP37/Ab+2BiGsw4j7nc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> btw, in page_referenced_one():
>=20
> +	if (mm !=3D current->mm && has_swap_token(mm))
> +		referenced++;
>=20
> what's the reason for the `mm !=3D current->mm' test?
>=20

so that you can steal pages from yourself if you really need to, say if
your own working set is bigger than ram.


--=-drP37/Ab+2BiGsw4j7nc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBDNBZxULwo51rQBIRAqpJAJ9PhrHstE3TvcA7jWYRxk1qoFoS9gCggnl7
rJRu6mCmVt9holUpSZuDgVM=
=V+aL
-----END PGP SIGNATURE-----

--=-drP37/Ab+2BiGsw4j7nc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
