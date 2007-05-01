Subject: Re: 2.6.22 -mm merge plans
From: Zan Lynx <zlynx@acm.org>
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-IqQA50TJqOTThI7AJ5O/"
Date: Tue, 01 May 2007 10:56:27 -0600
Message-Id: <1178038587.8420.3.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-IqQA50TJqOTThI7AJ5O/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-04-30 at 16:20 -0700, Andrew Morton wrote:
[snip]
> Mel's moveable-zone work.
>=20
> I don't believe that this has had sufficient review and I'm sure that it
> hasn't had sufficient third-party testing.  Most of the approbations thus=
 far
> have consisted of people liking the overall idea, based on the changelogs=
 and
> multi-year-old discussions.
>=20
> For such a large and core change I'd have expected more detailed reviewin=
g
> effort and more third-party testing.  And I STILL haven't made time to re=
view
> the code in detail myself.
[snip]

I am a fan of this, but I hadn't really realized that it's in -mm, and
that it has to be enabled with kernelcore=3D

Now that I am, I'm running it on my laptop with kernelcore=3D256M (it
wouldn't boot with 128M or less, weird initscript errors and OOMs).

1 GB single-core laptops are probably not the intended test audience :)
But I'll see what happens.
--=20
Zan Lynx <zlynx@acm.org>

--=-IqQA50TJqOTThI7AJ5O/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iD8DBQBGN3E7G8fHaOLTWwgRAhIdAJ9e49Rhfq/+WsyshWSYcmuFVt7aqwCcCRno
2aUmJ77bxGjZbxaCUg7+PMY=
=QvFN
-----END PGP SIGNATURE-----

--=-IqQA50TJqOTThI7AJ5O/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
