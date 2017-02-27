Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85D3A6B038C
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:40:59 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y51so5153908wry.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:40:59 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id j4si21582620wrj.278.2017.02.27.06.40.58
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 06:40:58 -0800 (PST)
Date: Mon, 27 Feb 2017 15:40:57 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 8/8] ARM: sun8i: a33: Add the Mali OPPs
Message-ID: <20170227144057.in7uclundvd77s5q@lukather>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <2e4a4f3f2f584f65f3c2d5e78f589015c651198d.1486655917.git-series.maxime.ripard@free-electrons.com>
 <20170215234029.3vfh25gxtvz44dsw@rob-hp-laptop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="vlqthyvsp4cqgzwc"
Content-Disposition: inline
In-Reply-To: <20170215234029.3vfh25gxtvz44dsw@rob-hp-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--vlqthyvsp4cqgzwc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 15, 2017 at 05:40:29PM -0600, Rob Herring wrote:
> On Thu, Feb 09, 2017 at 05:39:22PM +0100, Maxime Ripard wrote:
> > The Mali GPU in the A33 has various operating frequencies used in the
> > Allwinner BSP.
> >=20
> > Add them to our DT.
> >=20
> > Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> > ---
> >  arch/arm/boot/dts/sun8i-a33.dtsi | 17 +++++++++++++++++
> >  1 file changed, 17 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/arch/arm/boot/dts/sun8i-a33.dtsi b/arch/arm/boot/dts/sun8i=
-a33.dtsi
> > index 043b1b017276..e1b0abfee42f 100644
> > --- a/arch/arm/boot/dts/sun8i-a33.dtsi
> > +++ b/arch/arm/boot/dts/sun8i-a33.dtsi
> > @@ -101,6 +101,22 @@
> >  		status =3D "disabled";
> >  	};
> > =20
> > +	mali_opp_table: opp_table1 {
>=20
> gpu-opp-table

Applied with that change. Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--vlqthyvsp4cqgzwc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYtDp5AAoJEBx+YmzsjxAgUCYP/3QB1y2wH9sSn2RY8/KkUq40
B9PW7zWPs4HK0kDloEBlIlAmvqcfZqnjXE5dAmPy0sWKfCT3VEbX7BaxkIdA5STU
mvJVdpd544sE/Rj5Pd4z1a+dJjYRMSRYhIkDeyvnAjFo7nvvNv5yRQmN8H4XW2ce
qF6GylTO+bufxqM1oqF3qGhpwfm4ezyLc+sMCv0DMzuVZPjXkIwmZNZytB/jHgyq
ttaV6jUzbpwtxALLhcGZQUanFTlzXD3v/cCE1OW5P6Pdc9OC0CU3dGQYp+sFxweJ
qDXtx/rEFpHPJ9XdVbs9d5KlsEphbep+RkKOQ0qIjgDvdd8/N6I/RZBUblPoCMaV
pYEpEq/+Xe6l5zqusyPhGIFZ3bRH55b7owkSmOM0YQwH8DQdzq7E52n4mkR14ixJ
zNV0TgWTwqM40lijsVD/qeIpOlLBFxgABuUnCsPjpUCY2e8Rin7ZCMyJUPN6KWos
Ni48r053krU8HWgLzvoJySS/nFP03Tk/T+azUe4z8Ml5FpwVWMiPnAEYEs06AoNc
D3j/V5qId0OYAeAfABKmnl2TkP4LoBYD9/L0B5McuVsOgXdLtl4xW6kEEpS4+yt2
wmhf0e/NWcZPxik2nYtN5RsuasJ+feeUF9gUC4FGNHIaAUQSBN9HtLTiAFfHSAiI
/BCtGbbFoukHMdFYfgVI
=+uJf
-----END PGP SIGNATURE-----

--vlqthyvsp4cqgzwc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
