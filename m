Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A48D440602
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:43:43 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so8932679wjd.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:43:43 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id i3si13736563wrc.130.2017.02.17.07.43.41
        for <linux-mm@kvack.org>;
        Fri, 17 Feb 2017 07:43:41 -0800 (PST)
Date: Fri, 17 Feb 2017 16:43:41 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <20170217154341.vn7uqvdaijtrj64s@lukather>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <20170216184524.cxcy2ux37yrwutla@lukather>
 <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="7wd4bnkoxq5lsnle"
Content-Disposition: inline
In-Reply-To: <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Cc: ML dri-devel <dri-devel@lists.freedesktop.org>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, wens@csie.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org


--7wd4bnkoxq5lsnle
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 17, 2017 at 01:45:44PM +0100, Tobias Jakobi wrote:
> Hello Maxime,
>=20
> Maxime Ripard wrote:
> > Hi,
> >=20
> > On Thu, Feb 16, 2017 at 01:43:06PM +0100, Tobias Jakobi wrote:
> >> I was wondering about the following. Wasn't there some strict
> >> requirement about code going upstream, which also included that there
> >> was a full open-source driver stack for it?
> >>
> >> I don't see how this is the case for Mali, neither in the kernel, nor =
in
> >> userspace. I'm aware that the Mali kernel driver is open-source. But it
> >> is not upstream, maintained out of tree, and won't land upstream in its
> >> current form (no resemblence to a DRM driver at all). And let's not ta=
lk
> >> about the userspace part.
> >>
> >> So, why should this be here?
> >=20
> > The device tree is a representation of the hardware itself. The state
> > of the driver support doesn't change the hardware you're running on,
> > just like your BIOS/UEFI on x86 won't change the device it reports to
> > Linux based on whether it has a driver for it.
>
> Like Emil already said, the new bindings and the DT entries are solely
> introduced to support a proprietary out-of-tree module.

No. This new binding and the DT entries are solely introduced to
describe a device found in a number of SoCs, just like any other DT
binding we have.

> The current workflow when introducing new DT entries is the following:
> - upstream a driver that uses the entries
> - THEN add the new entries

And that's never been the preferred workflow, for *any* patches.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--7wd4bnkoxq5lsnle
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYpxopAAoJEBx+YmzsjxAgRAEQAIFTvLi6XXzNqh43UxsBUkKX
XUg7LN/oZiG8UKmk9Q0mDSaygiGpO3kZF4wQIjakrKPzGRhxfhDahrKvDXVja3dq
jit06bhZDqFi33EgevOodIdTidvxaI4juisv6eNthYaBZ6i3qH5HeTmqEYMjCCNl
ehY4yEwq4N/nSXlTgMz8tFZS/7T0E4L1/Cm4fHPoBcVORdIgFEjQm/ROwkK0r6TF
gFzOodC0qEKrR5zrMtWLyXDrqLu64DQYGSEFC6KiyXGE8pnBXs228IAjSsqetPgF
Xlh6pTO+XtJs4IXVX0BgzLlkZAWm0rLlJyCzC37IAy7tnk9mP/5LAWBxc029PhYI
LcXDuw9xjyn5Y+vqzqfdRm3eQTvQcY0z0oODI3W6h6HXAKLsA1vvTKJgapO5eQIH
eIcZDjDmbq+EKu95aBfN+pV0GL1v8ByZmibYxubZpU6mfAcdb/MO5WlUvZPybMJI
RhDm7ZeiPqK2EnyYkcc+1iQK5Xvp4C/Q3POcXecCBKKGgNfiImmyv1pHIkKoUFuO
jxOeCaNcD4o8G4mqrP0YGoyFbap1Pi1+nFRktu742HXkPQqPIJP1KToUq3cnTilG
j+1JIeqWiZNZTYx2f9Vwwrjv/INX920v2gLSnTHEhIRT61/rV6UjYtwILZ60TUmf
itic3SYwoNabfD+iENcW
=4SNx
-----END PGP SIGNATURE-----

--7wd4bnkoxq5lsnle--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
