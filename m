Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A726E6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:39:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r18so39194774wmd.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:39:15 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id w185si13719206wmf.134.2017.02.27.06.39.14
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 06:39:14 -0800 (PST)
Date: Mon, 27 Feb 2017 15:39:13 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 1/8] ARM: sun8i: Fix the mali clock rate
Message-ID: <20170227143913.ld3rxwicjvjnrbgl@lukather>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <4830ced34cc83058f7cad123be67fecc624a99d6.1486655917.git-series.maxime.ripard@free-electrons.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="kixm2n2tbdlgilfj"
Content-Disposition: inline
In-Reply-To: <4830ced34cc83058f7cad123be67fecc624a99d6.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--kixm2n2tbdlgilfj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 09, 2017 at 05:39:15PM +0100, Maxime Ripard wrote:
> The Mali clock rate was improperly assumed to be 408MHz, while it was
> really 384Mhz, 408MHz being the "extreme" frequency, and definitely not
> stable.
>=20
> Switch for the stable, correct frequency for the GPU.
>=20
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied.
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--kixm2n2tbdlgilfj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYtDoNAAoJEBx+YmzsjxAgjKQQAItWJ3B4OLG11wZvzbXUl6/K
ngSsCsKHCOPxeC7ZV9sFjEN0yPW9lLccR2en6XzwVWEtooe1JddJBWa3teka6/yO
Q7O4+MCPpiI92WAEXyCVT79+1VF0wyExMdEU80XEEpJMwtT4WcHDgzXKVNOYIP+L
7WyTC59t7P5L8+HuIyEeSPUMUxkelRKDW0CoNEQ/jRL1DEpcAtDRa0WBFufv1sgh
NuDYSSLMQ7FuYLzoGNakLFwV7JPg5XdeG0nYf/9lPA0njZ4j3qr2l1U1+IPubC2M
SU2FJfwjbJR2SMaa+ql8lLiq1h35SrVPVgFSz2cN17IUsoDtJ7FzMNTjttxkpvRc
xwrb3J2hiFPogVJs3Fey8RTOThwumRKqaNuq04onhDmfSgX82CCXl0KrfwyubU3j
RytszpLTLE2jvtnq7CKImHPHdw04PftHLzUubMYV/YfBFy5FbT1Lqb/sehqb6Nsh
iKi9JH0CylqZkFnfj5qhLehr9wLtlfgcto0E7YEgUdUXrDGT6YoBybPp0l466wvk
MzvdR9vCfMbqwxWSgkz88xNMIdOMIdKbNMMTkSr6z2FW7Iez3gFWzaq1ySX3cH4/
OqbiCfAxpWgSDhAhJfEO2RWc+MQ64kcux2V/THkZIM68Pk4zHA1Sv7z3E3Sx7Vew
J6y8WW6N5Ueaj889L/r0
=LTOV
-----END PGP SIGNATURE-----

--kixm2n2tbdlgilfj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
