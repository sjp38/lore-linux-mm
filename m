Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 63D416B0062
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 09:57:12 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id k6so1368937lbo.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 06:57:10 -0700 (PDT)
Date: Sun, 21 Oct 2012 19:57:01 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121021195701.7a5872e7@sacrilege>
In-Reply-To: <1350826183.13333.2243.camel@edumazet-glaptop>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
	<20121021044540.12e8f4b7@sacrilege>
	<20121021062402.7c4c4cb8@sacrilege>
	<1350826183.13333.2243.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/OFE92=iTXLDHyKDYJJrneBG"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/OFE92=iTXLDHyKDYJJrneBG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 21 Oct 2012 15:29:43 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

>=20
> Did you try linux-3.7-rc2 (or linux-3.7-rc1) ?
>=20

I did not, will do in a few hours, thanks for the pointer.


--=20
Mike Kazantsev // fraggod.net

--Sig_/OFE92=iTXLDHyKDYJJrneBG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCD/zAACgkQASbOZpzyXnE4igCdFyBeCNPZLfLVbkMe0a2SMp8Q
SycAoJBqh+HaRGzg/y5s+Dhilk4qLp5r
=yWCH
-----END PGP SIGNATURE-----

--Sig_/OFE92=iTXLDHyKDYJJrneBG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
