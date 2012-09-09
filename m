Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D51AF6B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 14:27:15 -0400 (EDT)
Message-ID: <1347215223.7709.59.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Consider for longterm kernels: mm: avoid swapping out with
 swappiness==0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 09 Sep 2012 19:27:03 +0100
In-Reply-To: <504CCECF.9020104@redhat.com>
References: <5038E7AA.5030107@gmail.com>
	 <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk>
	 <504CCECF.9020104@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qo1euccM/K/4AbVvsPpC"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Zdenek Kaspar <zkaspar82@gmail.com>, linux-mm@kvack.org


--=-qo1euccM/K/4AbVvsPpC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-09-09 at 13:15 -0400, Rik van Riel wrote:
> On 09/09/2012 12:57 PM, Ben Hutchings wrote:
> > On Sat, 2012-08-25 at 16:56 +0200, Zdenek Kaspar wrote:
> >> Hi Greg,
> >>
> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dcom=
mit;h=3Dfe35004fbf9eaf67482b074a2e032abb9c89b1dd
> >>
> >> In short: this patch seems beneficial for users trying to avoid memory
> >> swapping at all costs but they want to keep swap for emergency reasons=
.
> >>
> >> More details: https://lkml.org/lkml/2012/3/2/320
> >>
> >> Its included in 3.5, so could this be considered for -longterm kernels=
 ?
> >
> > Andrew, Rik, does this seem appropriate for longterm?
>=20
> Yes, absolutely.  Default behaviour is not changed at all, and
> the patch makes swappiness=3D0 do what people seem to expect it
> to do.

OK, I've queued this up for 3.2.

Ben.

--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at once.

--=-qo1euccM/K/4AbVvsPpC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUEzfd+e/yOyVhhEJAQqAxw/+O7PNZV1Sw9nlghBK2kGlUeIog84QRDta
njwkxcjlDoGUEuAP7YlcS8+vrNfi5rr7axX33RVrOnuupu84RsSKNfr+6UEbY1F+
MojD9LQ79tZ7JNtemeLHAFc++TCGJuQZIYvqqMqNj7aGzldrOuWvOtLRVNqQUZB2
xVXSsB9LJ134w36tbIm7n/uFrbtVk9VsEpsZPwG7MSldwgWDCJiFM6iY3FzCTL5K
8JdEnvsPPVRaUaDd7/JioJwAoqkSy+mQDalFA81l0JDpy/sVALww3jLSV7lU9/it
Xsd9xbDtK0e3ydNi1GYnW0Pknqa6qs69QLy/pKCOJEqDKIGeUnAjo8Zz8hEIL9Fc
dkqkeahFasi69he6di+FeLsy/UWFwgZjcLYxz72t9WcLVhczMZjEsM6X5o1jvHka
A2mXsyRas+8JOAYw/dBMVjAE1LuLvtpl7+5A3ZImQkLejnejqEEGm0BRUjW8jv1a
g3+WvlYRuBc6HQYQ6kDaCHlcun1+Qn74wifFolW+1GdKQddysZxbBhONnN7CvSUS
zFmWJTku1S1zUS0dDuD8qZBZVzabkbdtrWNzIqEsZb8oqZG99ySmcdOWCKX5tDCK
PFWq0GiFlD5LDfSEH1cnd0mskIgRnwkAlT/BOfV4TuA4ogYe6opnQPnUGVJ+ONwL
gTrSRhYm/0g=
=Moan
-----END PGP SIGNATURE-----

--=-qo1euccM/K/4AbVvsPpC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
