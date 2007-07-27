Message-ID: <46A9F3DA.2090203@imap.cc>
Date: Fri, 27 Jul 2007 15:32:10 +0200
From: Tilman Schmidt <tilman@imap.cc>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>	 <46A773EA.5030103@gmail.com>	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>	 <46A81C39.4050009@gmail.com>	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>	 <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>	 <46A98A14.3040300@gmail.com> <1185522844.6295.64.camel@Homer.simpson.net>	 <46A9ACB2.9030302@gmail.com> <1185528368.7851.44.camel@Homer.simpson.net>	 <46A9D26E.9010703@gmail.com> <1185536880.8978.34.camel@Homer.simpson.net> <46A9E4FC.80403@gmail.com>
In-Reply-To: <46A9E4FC.80403@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig57656030EDDE835AF478E4E6"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>, Jesper Juhl <jesper.juhl@gmail.com>, Andika Triwidada <andika@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, B.Steinbrink@gmx.de, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig57656030EDDE835AF478E4E6
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Rene Herman schrieb:
> On 07/27/2007 01:48 PM, Mike Galbraith wrote:
>=20
>> I believe the users who say their apps really do get paged back in
>> though, so suspect that's not the case.
>=20
> Stopping the bush-circumference beating, I do not. -ck (and gentoo) hav=
e=20
> this massive Calimero thing going among their users where people are mu=
ch=20
> less interested in technology than in how the nasty big kernel meanies =
are=20
> keeping them down (*).

I think the problem is elsewhere. Users don't say: "My apps get paged
back in." They say: "My system is more responsive". They really don't
care *why* the reaction to a mouse click that takes three seconds with
a mainline kernel is instantaneous with -ck. Nasty big kernel meanies,
OTOH, want to understand *why* a patch helps in order to decide whether
it is really a good idea to merge it. So you've got a bunch of patches
(aka -ck) which visibly improve the overall responsiveness of a desktop
system, but apparently no one can conclusively explain why or how they
achieve that, and therefore they cannot be merged into mainline.

I don't have a solution to that dilemma either.

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig57656030EDDE835AF478E4E6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGqfPjMdB4Whm86/kRAsblAJ9UaxX+tApYsxEJui6A4QFvZ8AXeACfdhB5
Yj6CyRC0P4nqzC3+cW0K1k0=
=mEA1
-----END PGP SIGNATURE-----

--------------enig57656030EDDE835AF478E4E6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
