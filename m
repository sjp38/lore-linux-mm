Subject: Re: [PATCH] Clear dirty bits etc on compound frees
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <33500000.1070307646@flay>
References: <22420000.1069877625@[10.10.2.4]>  <33500000.1070307646@flay>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vRYDo1LEUjBuHdAPj2ZW"
Message-Id: <1070358901.5223.1.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Tue, 02 Dec 2003 10:55:02 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm mailing list <linux-mm@kvack.org>, Guillaume Morin <guillaume@morinfr.org>
List-ID: <linux-mm.kvack.org>

--=-vRYDo1LEUjBuHdAPj2ZW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I think you can reproduce this without the driver he's playing with
> by mmap'ing /dev/mem, and writing into any clustered page group (that
> a driver might have created or whatever).

that is an offence the program author should be shot for and then
chastized and ... ;)

--=-vRYDo1LEUjBuHdAPj2ZW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/zGF1xULwo51rQBIRAmEXAJ9r2M/ynPfgsGGjNARUCvyauwnrXACeMczw
6Wzr67v2As9SLIxWhhrJp9w=
=P0Gw
-----END PGP SIGNATURE-----

--=-vRYDo1LEUjBuHdAPj2ZW--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
