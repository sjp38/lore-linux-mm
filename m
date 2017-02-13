Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 995F36B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:44:18 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r18so42561607wmd.1
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:44:18 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id 36si13862130wrk.321.2017.02.13.05.44.17
        for <linux-mm@kvack.org>;
        Mon, 13 Feb 2017 05:44:17 -0800 (PST)
Date: Mon, 13 Feb 2017 14:44:16 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 3/8] mm: cma: Export a few symbols
Message-ID: <20170213134416.akgmtv3lv5m65fwx@lukather>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <2dee6c0baaf08e2c7d48ceb7e97e511c914d0f87.1486655917.git-series.maxime.ripard@free-electrons.com>
 <20170209192046.GB31906@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="iogrnqcox7foauu7"
Content-Disposition: inline
In-Reply-To: <20170209192046.GB31906@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Joonsoo Kim <js1304@gmail.com>, m.szyprowski@samsung.com


--iogrnqcox7foauu7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Michal,

On Thu, Feb 09, 2017 at 08:20:47PM +0100, Michal Hocko wrote:
> [CC CMA people]
>=20
> On Thu 09-02-17 17:39:17, Maxime Ripard wrote:
> > Modules might want to check their CMA pool size and address for debuggi=
ng
> > and / or have additional checks.
> >=20
> > The obvious way to do this would be through dev_get_cma_area and
> > cma_get_base and cma_get_size, that are currently not exported, which
> > results in a build failure.
> >=20
> > Export them to prevent such a failure.
>=20
> Who actually uses those exports. None of the follow up patches does
> AFAICS.

This is for the ARM Mali GPU driver that is out of tree, unfortunately.

In one case (using the legacy fbdev API), the driver wants to (and
probably should) validate that the buffer as indeed been allocated
=66rom the memory allocation pool.

Rob suggested that instead of hardcoding it to cover the whole RAM
(which defeats the purpose of that check in the first place), we used
the memory-region bindings in the DT and follow that, which does work
great, but we still have to retrieve the base address and size of that
region, hence why this patches are needed.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--iogrnqcox7foauu7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYobgtAAoJEBx+YmzsjxAggxQP/iijuozzzXD86tHgt+etXoXI
zCed54DPV5qc9UO7p3Xp8zx6YYBXYrp6jfO4Pn8wRAQMeum2MPKhsUbakf1vGQ/T
U+JNR1hOeB9tQ9tZrVkyGVQ2sQsoHxVjfn6Iqrsbyp5QSEcanoELKX6xPsFNKg7X
FrGvvugXcp+zIsdi9Tmn5BvFEBM+jf+fDlyMkLEKmdUQ/L1Vg+P2IAKqLNpOeXz0
fAxq1k2EB+gdWksP3kirfy+A+5l0E1OAWKZyk5+sUmGhToeoWrGw3yTPGNTfj0yA
Hwaq0yq27KuOSECnLkQ7myjLwDR0CuExuO7HHwG9IiKYd+kOpJAc12eFhEzl0LL+
X5ugij4mkMjGzh78PaMpH0TsFPBSNlaPzsk3xOfZwa77A/Phpj7IZBxH/7gYG6oS
vrVIYiJkrfp25rUKSlu1gnH8NjmOMzm9l1n5mcsAe4JCgORbjtDXJ194bl5YMdZv
JASjOMQpk/ukxeyee8mCRrLgiEkhM0eOKarKyK2ctENjgzq+nDF9syQN7uMqFkFH
sOAVMbvEw7jnwrJHK4hwNdEv8FGD6QC6SxwGhiH+HIPgFk9AL0whq+x236lT0LRD
uaMuuVT0dqo1eJG9kmzAMg0Q425Rd49vdNMZlMzaHs0YhsdRuowaxFpZ+yimWBSo
ik3u+FYdhhh5xxBILxzr
=Ltyc
-----END PGP SIGNATURE-----

--iogrnqcox7foauu7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
