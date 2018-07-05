Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 15EF26B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 00:37:33 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 39-v6so1154741ple.6
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 21:37:33 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id y71-v6si4692855pgd.223.2018.07.04.21.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Jul 2018 21:37:31 -0700 (PDT)
Date: Thu, 5 Jul 2018 14:37:26 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: XArray -next inclusion request
Message-ID: <20180705143726.3ec5e77a@canb.auug.org.au>
In-Reply-To: <20180704225431.GA16309@bombadil.infradead.org>
References: <20180617021521.GA18455@bombadil.infradead.org>
	<20180617134104.68c24ffc@canb.auug.org.au>
	<20180704225431.GA16309@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/2u+J8f_.TkC=Al/t6PlP1PA"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/2u+J8f_.TkC=Al/t6PlP1PA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Willy,

On Wed, 4 Jul 2018 15:54:31 -0700 Matthew Wilcox <willy@infradead.org> wrot=
e:
>
> I have some additional patches for the IDA that I'd like to
> send to Linus as a separate pull request.  Unfortunately, they conflict w=
ith
> the XArray patches, so I've done them as a separate branch in the same tr=
ee:
>=20
> git://git.infradead.org/users/willy/linux-dax.git ida
>=20
> Would you prefer to add them as a separate branch to linux-next (to be
> pulled after xarray), or would you prefer to replace the xarray pull
> with the ida pull?  Either way, you'll get the same commits as the ida
> branch is based off the xarray branch.

I have added that as a new tree from today.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgement of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
        Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

--Sig_/2u+J8f_.TkC=Al/t6PlP1PA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAls9oIYACgkQAVBC80lX
0GyA6Qf9E96YAJqveWQemXWqUNd++DgTtmwPWP5y/5w4Oh95tM5IT2iVjLnvqKLE
F3a8NX4jpqWezgdOJAb5r9IPbosGRabgGNLvluET82kVfcs2KIsK4ITsAmuqmjt0
5Hf1zynH/GOXXhGqOfkbfr3xyQqFTETyOYv67Jy4l6NCWNO8HP0lNb9qfbUZcOH2
y4ARndfMobDYXpGOlGHPIiHz6TzOH+epEI5Vtl1kW91TvqfM0FMyuIsMQptZE+es
DyaQ7VTmhTP55tZE/RAwX5rNgrfXMYE1jUTZqs9lw7v3OnVZzxbDIVnVXvCL+gxl
4sY69QdBR2EVykYmD9KVeAMbC4IqUA==
=XVdQ
-----END PGP SIGNATURE-----

--Sig_/2u+J8f_.TkC=Al/t6PlP1PA--
