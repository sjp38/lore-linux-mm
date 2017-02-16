Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFC60681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:39:08 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id b51so473174wrb.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 00:39:08 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id 89si12448931wre.175.2017.02.17.00.39.07
        for <linux-mm@kvack.org>;
        Fri, 17 Feb 2017 00:39:07 -0800 (PST)
Date: Thu, 16 Feb 2017 19:45:24 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <20170216184524.cxcy2ux37yrwutla@lukather>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="mwgnzn5pgd7q2te4"
Content-Disposition: inline
In-Reply-To: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>
Cc: ML dri-devel <dri-devel@lists.freedesktop.org>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, wens@csie.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org


--mwgnzn5pgd7q2te4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Feb 16, 2017 at 01:43:06PM +0100, Tobias Jakobi wrote:
> I was wondering about the following. Wasn't there some strict
> requirement about code going upstream, which also included that there
> was a full open-source driver stack for it?
>=20
> I don't see how this is the case for Mali, neither in the kernel, nor in
> userspace. I'm aware that the Mali kernel driver is open-source. But it
> is not upstream, maintained out of tree, and won't land upstream in its
> current form (no resemblence to a DRM driver at all). And let's not talk
> about the userspace part.
>=20
> So, why should this be here?

The device tree is a representation of the hardware itself. The state
of the driver support doesn't change the hardware you're running on,
just like your BIOS/UEFI on x86 won't change the device it reports to
Linux based on whether it has a driver for it.

So yes, unfortunately, we don't have a driver upstream at the
moment. But that doesn't prevent us from describing the hardware
accurately.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--mwgnzn5pgd7q2te4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYpfNEAAoJEBx+YmzsjxAgOqQP/0aWELdbKTPpplGHgwAUT0mf
zUVVBrPG9OLld83v9xl9rED7+0g+QNh9I34Sj+KVxMJZw0oe/pshzAbRQcuRBbZT
YNERyUbSIb8WDncboZVY1nSMmZp7HJENzvKwI7vYds1qy5nRRbXuSt8HHf1rCO6H
a6i/TkuPPJZXlK3pdNCoPQLDAZXQ7/6x9tyaQEnmyBH4Mjp7B9dbCT9Q6Lp0ASA7
Bg+oCnr/QBoSEdNpLY7hwqVtUgPpmxjdhFqiSo5w6bQr0NVlngtb6tZ1qJCtEXpa
BU+5l5Gbw9FQHbnMqut66q8ynsg4czpWTnY0sMclTEJVEiHdA7JJDUz+mIgMloyb
NItlJhrL0P+Z9rwnsY/EzL4A4I8VYwV5C6PBel9VZOCtsid8EaHeFgAGDXq2s2ZJ
xH85oOhvtcNGspAEU4kT7CPO0HYt3h2XVfR3m73U3+5rVzngnbinTevu7fINHesc
2q2VW6Hrt5XaooBV71tBguxMatoemueX95FTzx4bsEGNVHftM7hchuBWWkLK1H6E
taY0Bg9euE2r2WKmv5WXobRIktuu9Y5yKFJb2yHIdhp8csIEw+RgJfMPGAuHQKNu
4VSaOfnWFkiZAexSnCRoUSYL+RcOib1tH0jW7L76I6KZbfKp3BAljrjpQZeoATs7
VEW+VuPwXEW79Doegrux
=N7Gb
-----END PGP SIGNATURE-----

--mwgnzn5pgd7q2te4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
