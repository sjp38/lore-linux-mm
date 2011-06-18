Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 03BE36B004A
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 14:41:26 -0400 (EDT)
Message-ID: <4DFCF13F.50401@cslab.ece.ntua.gr>
Date: Sat, 18 Jun 2011 21:41:03 +0300
From: Vasileios Karakasis <bkk@cslab.ece.ntua.gr>
MIME-Version: 1.0
Subject: Re: [BUG] Invalid return address of mmap() followed by mbind() in
 multithreaded context
References: <4DFB710D.7000902@cslab.ece.ntua.gr> <20110618181232.GI16236@one.firstfloor.org>
In-Reply-To: <20110618181232.GI16236@one.firstfloor.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1CC55EF867D4A735A093B854"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1CC55EF867D4A735A093B854
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

That's right, but what I want to demonstrate is that the address
returned by mmap() is invalid and the dereference crashes the program,
while it shouldn't. I could equally omit this statement, in which case
mbind() would fail with EFAULT.

On 06/18/2011 09:12 PM, Andi Kleen wrote:
>>     for (i =3D 0; i < NR_ITER; i++) {
>>         addr =3D mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE,
>>                     MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
>>         if (addr =3D=3D (void *) -1) {
>>             assert(0 && "mmap failed");
>>         }
>>         *addr =3D 0;
>>
>>         err =3D mbind(addr, PAGE_SIZE, MPOL_BIND, &node, sizeof(node),=
 0);
>=20
> mbind() can be only done before the first touch. you're not actually te=
sting=20
> numa policy.
>=20
> -andi

--=20
V.K.


--------------enig1CC55EF867D4A735A093B854
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk388U0ACgkQHUHhfRemepxHwwCg8nBwl3ZuVdCmwEecizOdDuOM
680An3lRmAFNS5Ek8ZQjBSPb5YUcqNwA
=CacT
-----END PGP SIGNATURE-----

--------------enig1CC55EF867D4A735A093B854--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
