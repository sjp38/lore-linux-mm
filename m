Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1EDF6B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 17:58:14 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u63so1018334wmu.0
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 14:58:14 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id x200si8156052wme.45.2017.02.23.14.58.13
        for <linux-mm@kvack.org>;
        Thu, 23 Feb 2017 14:58:13 -0800 (PST)
Date: Thu, 23 Feb 2017 14:58:09 -0800
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 3/8] mm: cma: Export a few symbols
Message-ID: <20170223225809.rnpbjnli4wa5kims@lukather>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <2dee6c0baaf08e2c7d48ceb7e97e511c914d0f87.1486655917.git-series.maxime.ripard@free-electrons.com>
 <20170209192046.GB31906@dhcp22.suse.cz>
 <20170213134416.akgmtv3lv5m65fwx@lukather>
 <20170220123550.GH2431@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="s63xugflc7zhlrdx"
Content-Disposition: inline
In-Reply-To: <20170220123550.GH2431@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Joonsoo Kim <js1304@gmail.com>, m.szyprowski@samsung.com


--s63xugflc7zhlrdx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 20, 2017 at 01:35:50PM +0100, Michal Hocko wrote:
> On Mon 13-02-17 14:44:16, Maxime Ripard wrote:
> > Hi Michal,
> >=20
> > On Thu, Feb 09, 2017 at 08:20:47PM +0100, Michal Hocko wrote:
> > > [CC CMA people]
> > >=20
> > > On Thu 09-02-17 17:39:17, Maxime Ripard wrote:
> > > > Modules might want to check their CMA pool size and address for deb=
ugging
> > > > and / or have additional checks.
> > > >=20
> > > > The obvious way to do this would be through dev_get_cma_area and
> > > > cma_get_base and cma_get_size, that are currently not exported, whi=
ch
> > > > results in a build failure.
> > > >=20
> > > > Export them to prevent such a failure.
> > >=20
> > > Who actually uses those exports. None of the follow up patches does
> > > AFAICS.
> >=20
> > This is for the ARM Mali GPU driver that is out of tree, unfortunately.
>=20
> We do not export symbols which do not have any in-tree users.

Ok, sorry for the noise.

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--s63xugflc7zhlrdx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYr2j9AAoJEBx+YmzsjxAg1psP/AxBecNFS/F6Lg4/68RQPm6E
aPq5uFQGu/20PngWJhVRT1XVvQGFTbzht/EZMrfOweSSvmRyguekdWD6zkxitxJO
gjAdoKU8WKzkDBEMsTh3dMQu/Gqfq6jaGeDwvJKcnlt7OpX7RJza75TJE1K2hkTH
IhNEa19Cs+8xbtDARDDnCsiVuZ42Gku16p8s/h7+jjgOdJoKmdXBQAoplCiWdftO
kqmGa2n4dAUC2S02ao8dpiiVjnnT4tBzMyoOY/HynaJ+IMLwhscFKa3f54SQX82h
3bKK8n+c2avDIm3pCot4UsJS+TcKmlVa0zd3NavrU5Vl+0qXr90MUPe4ULghb8qt
z2bSpib5V6PZJxScMNQRw6bcRHjeajL1PeeYJB9VTFATmHh3/oUrn6gJZ00ap2Hc
WnFZPb49z10eo0oHyU2wuktqxTPWn5brTLCMbTsGrmEZITPh9IaMaEOmJa+FFA6d
5zDqZr7YW4LZ9f72EsARbk8F3ZE6fzRzEPlje2Ea5hvOosi32/GjP7sX49wY/0zJ
qQeePSPGyueawsyRGTidK12iB/RM2dO9kDhbDr23pHdKDAZQ1cyKoeWI3SAzD+wN
VBnFmMn3aM/m6a5h+A8YUF2kOXDGQXIeUS54MTAGhWvVoBcqwpG82QgC5qer2y+G
dzqy1P6jVdM3MyR3IL+f
=88L1
-----END PGP SIGNATURE-----

--s63xugflc7zhlrdx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
