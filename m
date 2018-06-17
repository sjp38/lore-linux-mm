Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC136B027F
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 23:41:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c187-v6so6764085pfa.20
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 20:41:11 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id r85-v6si11734732pfa.259.2018.06.16.20.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 20:41:09 -0700 (PDT)
Date: Sun, 17 Jun 2018 13:41:04 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: XArray -next inclusion request
Message-ID: <20180617134104.68c24ffc@canb.auug.org.au>
In-Reply-To: <20180617021521.GA18455@bombadil.infradead.org>
References: <20180617021521.GA18455@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_//10i7lQzwXr2dcjDSpTezyV"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_//10i7lQzwXr2dcjDSpTezyV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Willy,

On Sat, 16 Jun 2018 19:15:22 -0700 Matthew Wilcox <willy@infradead.org> wro=
te:
>
> Please add
>=20
> git://git.infradead.org/users/willy/linux-dax.git xarray
>=20
> to linux-next.  It is based on -rc1.  You will find some conflicts
> against Dan's current patches to DAX; these are all resolved correctly
> in the xarray-20180615 branch which is based on next-20180615.

Added from tomorrow.

> In a masterstroke of timing, I'm going to be on a plane to Tokyo on
> Monday.  If this causes any problems, please just ignore the request
> for now and we'll resolve it when I'm available to fix problems.

No worries, I will check your other branch and if things are still to
difficult, you will get an email and I will just drop it for a few days.

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

--Sig_//10i7lQzwXr2dcjDSpTezyV
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlsl2FAACgkQAVBC80lX
0GyZmgf9HRW8/VuzETFcFcp0l4cXJLhNuCSRRP4FXGPKh6KJwwf0FIEW3hmwqoNj
ifKVtyBMtcLg3I6RSizxtAonQp6Cg8+pa84MA6B4I+wP4Dpb7OuhonqRd88oLn5J
7C453g0Deoq4v0vOwXb36WnaxHmo/HejWa8UFXwS9HuTWqCYWSshvWHyXLAUX1Ke
7XPlDXin/YnqxEyHMQokWI4YX1IO2JBzytqrDUPKtL11k20zl0C4JcAEJCTFG5l0
U8vhofT96EUCqCD9Ql7CC7mJIHo5yjZk0Arubd/RgcIm9RV7GWuua3jd//ElFaDb
hnwctZDxCzIYpKHRv3kDGPH2AORxoA==
=xx4Q
-----END PGP SIGNATURE-----

--Sig_//10i7lQzwXr2dcjDSpTezyV--
