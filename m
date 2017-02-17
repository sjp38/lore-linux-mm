Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08AA8440602
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:44:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c4so8916603wrd.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:44:20 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id n22si13713952wra.214.2017.02.17.07.44.19
        for <linux-mm@kvack.org>;
        Fri, 17 Feb 2017 07:44:19 -0800 (PST)
Date: Fri, 17 Feb 2017 16:44:19 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <20170217154419.xr4n2ikp4li3c7co@lukather>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <CACvgo51p+aqegjkbF6jGggwr+KXq_71w0VFzJvFAF6_egT1-kA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="i226xtpriqwemlpf"
Content-Disposition: inline
In-Reply-To: <CACvgo51p+aqegjkbF6jGggwr+KXq_71w0VFzJvFAF6_egT1-kA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emil Velikov <emil.l.velikov@gmail.com>
Cc: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>, ML dri-devel <dri-devel@lists.freedesktop.org>, Mark Rutland <mark.rutland@arm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, devicetree <devicetree@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>, LAKML <linux-arm-kernel@lists.infradead.org>


--i226xtpriqwemlpf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 16, 2017 at 04:54:45PM +0000, Emil Velikov wrote:
> On 16 February 2017 at 12:43, Tobias Jakobi
> <tjakobi@math.uni-bielefeld.de> wrote:
> > Hello,
> >
> > I was wondering about the following. Wasn't there some strict
> > requirement about code going upstream, which also included that there
> > was a full open-source driver stack for it?
> >
> > I don't see how this is the case for Mali, neither in the kernel, nor in
> > userspace. I'm aware that the Mali kernel driver is open-source. But it
> > is not upstream, maintained out of tree, and won't land upstream in its
> > current form (no resemblence to a DRM driver at all). And let's not talk
> > about the userspace part.
> >
> > So, why should this be here?
> >
> Have to agree with Tobias, here.
>=20
> I can see the annoyance that Maxime and others have to go through to
> their systems working.
> At the same time, changing upstream kernel to suit out of tree
> module(s) is not how things work. Right ?
>=20
> Not to mention that the series adds stable ABI exclusively(?) used by
> a module which does not seem to be in the process of getting merged.

It really doesn't have any relation to whether a particular component
is supported in Linux. Our git repo just happens to be the canonical
source of DT, but those DTs are also used in other systems and
projects that have *no* relation with Linux, and might have a
different view on things than we do.

There's been a long-running discussion about moving the DTs out of the
kernel and in a separate repo. Would you still be opposed to it if I
happened to contribute that binding to that repo, even if Linux didn't
have any in-tree support for it? I'm pretty sure you wouldn't, yet
this is the exact same case.

And taking the ACPI example once again, this doesn't seem to bother
you at all that ACPI reports that it has a device that is not
supported in-tree in Linux. Why is it any different in DT.

We already have DT bindings for out of tree drivers, there's really
nothing new here.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--i226xtpriqwemlpf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYpxpTAAoJEBx+YmzsjxAgE1oQAIah11MBHPFADoIFgRZiKVGm
fZZrhIlhO6qbZtIXfYcImTXsKQaH+2UmzByyjOHoKzXonV/HQE3nH+V6A38TmMTV
vP5uFpuIchVBr0vRjc1FkmFSio8uJFBHxH8uZnqddZNsh2s5n/Jfrux972wtX9CM
pFTJTPEjMV0YsqJpoGjvn7EgKWUEKT7qrpzVrk7kSIlYsvzjeEdd9jHLykS5yzwS
2jCfrUM6jNWmtoABV3blO37Mm/bJjdHN5slSL/ayUXVERUduEiqvUrepM6zNkZvw
qB11BXcyUbSUn5sawNEx5tyE/kLVF0+BWDKaC5H01cpPxns6KOVJpOsWNDESILSr
QvVzhyCO0NxBTQx4EhlYLfQiOxJr6q/541lImdfK/4bOHyOvkLGWKC+7i25WQrwc
cGgkijMWJZlC7siJwbAXD2duLhRydUbO7aMvqH89LeCYR6F3IZHSB0sCZYbB6eFz
kWBZOgyeLFWFsz/6a2VwULSRU+VFAhAldzPn4ajSCr9SjPE6kFQuvMLrf9uLfHTB
WdzTTSCGGchmwHgKUVmhmlU4k2rLDsGqbQlssKzG+vibL5TXwIfEIArazgLwDlQB
Gi5p4q7KsUdAcS/SqZ2x7Zo8TINRXi85QLnA5Pok/GTUWI/vh1EK3lFojeHmM4sx
DGreiIE7M2I/2C9JLdYA
=4WLJ
-----END PGP SIGNATURE-----

--i226xtpriqwemlpf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
