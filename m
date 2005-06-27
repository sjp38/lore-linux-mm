Subject: Re: [PATCH] 2/2 swap token tuning
From: Martin Schlemmer <azarah@nosferatu.za.org>
Reply-To: azarah@nosferatu.za.org
In-Reply-To: <Pine.LNX.4.61.0506270907110.18834@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0506261827500.18834@chimarrao.boston.redhat.com>
	 <Pine.LNX.4.61.0506261835000.18834@chimarrao.boston.redhat.com>
	 <1119877465.25717.4.camel@lycan.lan>
	 <Pine.LNX.4.61.0506270907110.18834@chimarrao.boston.redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-RY7037GX8qTCBZH8iqaZ"
Date: Mon, 27 Jun 2005 15:47:36 +0200
Message-Id: <1119880056.10872.0.camel@lycan.lan>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik Van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Song Jiang <sjiang@lanl.gov>
List-ID: <linux-mm.kvack.org>

--=-RY7037GX8qTCBZH8iqaZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2005-06-27 at 09:08 -0400, Rik Van Riel wrote:
> On Mon, 27 Jun 2005, Martin Schlemmer wrote:
>=20
> > -+				sem_is_read_locked(mm->mmap_sem))
> > +                               sem_is_read_locked(&mm->mmap_sem))
>=20
> Yes, you are right.  I sent out the patch before the weekend
> was over, before having tested it locally ;)
>=20
> My compile hit the error a few minutes after I sent out the
> mail, doh ;)
>=20
> Andrew has a fixed version of the patch already.
>=20

Ok, thanks - wanted to test it, and just wanted to verify that my
changes are OK.


Regards,

--=20
Martin Schlemmer


--=-RY7037GX8qTCBZH8iqaZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCwAN4qburzKaJYLYRAt5jAJ9hKGQ4Qgs9XKzjfjgqlKk4BqgMIACdHTMe
JNB+oyBcAw1YbPlyg/Qw0JY=
=CJMl
-----END PGP SIGNATURE-----

--=-RY7037GX8qTCBZH8iqaZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
