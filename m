Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7F06B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 19:44:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id x4so9024wme.3
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 16:44:20 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id y141si4159742wmc.96.2017.02.22.16.44.18
        for <linux-mm@kvack.org>;
        Wed, 22 Feb 2017 16:44:18 -0800 (PST)
Date: Wed, 22 Feb 2017 16:44:04 -0800
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <20170223004404.jyxlvvsoojw7qnud@lukather>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <20170216184524.cxcy2ux37yrwutla@lukather>
 <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
 <20170217154341.vn7uqvdaijtrj64s@lukather>
 <20170220164926.GB15493@ulmo.ba.sec>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="hiiboxguzdlnzlgo"
Content-Disposition: inline
In-Reply-To: <20170220164926.GB15493@ulmo.ba.sec>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>, Mark Rutland <mark.rutland@arm.com>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, ML dri-devel <dri-devel@lists.freedesktop.org>, linux-mm@kvack.org, wens@csie.org, Rob Herring <robh+dt@kernel.org>, linux-arm-kernel@lists.infradead.org


--hiiboxguzdlnzlgo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Thierry,

On Mon, Feb 20, 2017 at 05:49:26PM +0100, Thierry Reding wrote:
> On Fri, Feb 17, 2017 at 04:43:41PM +0100, Maxime Ripard wrote:
> > On Fri, Feb 17, 2017 at 01:45:44PM +0100, Tobias Jakobi wrote:
> > > Hello Maxime,
> > >=20
> > > Maxime Ripard wrote:
> > > > Hi,
> > > >=20
> > > > On Thu, Feb 16, 2017 at 01:43:06PM +0100, Tobias Jakobi wrote:
> > > >> I was wondering about the following. Wasn't there some strict
> > > >> requirement about code going upstream, which also included that th=
ere
> > > >> was a full open-source driver stack for it?
> > > >>
> > > >> I don't see how this is the case for Mali, neither in the kernel, =
nor in
> > > >> userspace. I'm aware that the Mali kernel driver is open-source. B=
ut it
> > > >> is not upstream, maintained out of tree, and won't land upstream i=
n its
> > > >> current form (no resemblence to a DRM driver at all). And let's no=
t talk
> > > >> about the userspace part.
> > > >>
> > > >> So, why should this be here?
> > > >=20
> > > > The device tree is a representation of the hardware itself. The sta=
te
> > > > of the driver support doesn't change the hardware you're running on,
> > > > just like your BIOS/UEFI on x86 won't change the device it reports =
to
> > > > Linux based on whether it has a driver for it.
> > >
> > > Like Emil already said, the new bindings and the DT entries are solely
> > > introduced to support a proprietary out-of-tree module.
> >=20
> > No. This new binding and the DT entries are solely introduced to
> > describe a device found in a number of SoCs, just like any other DT
> > binding we have.
> >=20
> > > The current workflow when introducing new DT entries is the following:
> > > - upstream a driver that uses the entries
> > > - THEN add the new entries
> >=20
> > And that's never been the preferred workflow, for *any* patches.
>=20
> Actually it has. How else are you going to test that your driver really
> works? You've got to have both pieces before you can verify that they're
> both adequate. So the typical workflow is to:
>=20
> 	1) define the bindings
> 	2) write a driver that implements the bindings
> 	3) add entries to device tree files
>=20
> Usually it doesn't matter in which order you do the above because they
> are all part of the same patch series. But that's not what you're doing
> here. The more general problem here is that you're providing device tree
> content (and therefore ABI) that's based on a binding which has no
> upstream users. So you don't actually have a way of validating that what
> you merge is going to be an adequate description.
>=20
> You're probably going to respond: "but DT describes hardware, so it must
> be known already, there won't be a need for changes". Unfortunately that
> is only partially true. We've had a number of occasions where it later
> turned out that a binding was in fact not an adequate description, and
> then we've had to jump through hoops in order to preserve backwards
> compatibility. That's already annoying enough if you've got in-tree
> users, but it's going to be even more painful if you start out with an
> out-of-tree user.
>=20
> All of that said, you've got an Acked-by from Rob and that's about as
> good as it's going to get. So I'm not going to NAK this. But I will
> caution against this, because I don't think you're doing yourself any
> favours with this.
>=20
> So perhaps the question that we should ask is this: what do you gain by
> merging this series? The fact remains that you don't have an upstream
> driver that implements this binding, so ultimately you're going to be
> carrying patches in some development tree anyway. Why not simply stash
> these patches into the same tree? That should be about the same amount
> of work for you and your users, but it has the advantage of not locking
> you into something that you may regret.

This is really a usability issue. I don't want the average Jane / Joe
to have to patch and recompile the DT in order to get the GPU running
on her / his distro of choice. The only thing that should be needed
would be to install an (or a couple of) extra package in order to get
everything running. Just like it's done for any other GPU out there,
or wifi, disregarding whether it's supported upstream or not.

Another nice thing is also that the mali bindings have been a huge
mess so far. If we have a common bindings, everything will just work
the same for all the platforms, and we can use the same driver there,
allowing us at least to consolidate the source code.

I'm not too afraid about getting something wrong. We already have code
working for two different vendors, and all the other GPUs already
described in DT (nvidia's, the Adreno) all have the same kind of
binding that we have.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--hiiboxguzdlnzlgo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYrjBQAAoJEBx+YmzsjxAgIaEP/3paB8DgNmiCfEMIBgkFENK8
Xuor5wY0q/jLibY5mdz1JOMSG5iUFmUR4A8lrXWM5xa8m3aza/5shsMLfr+1fRjn
909+LL5C1uvmADVJV7buEqfYUISuk5ADDn+eySFxdJjd7+rxb1jQZ8DloaY0ozPY
gJ2yMbYIH9LenEdl/gIq6lvIRCGLpcZmA9BdV1zjgql1mNzh/Yqa/2amImjFCccW
gqjFSkn94gDRvW5+1fOycoI839V+wRlOddghLDcbYlejOrMWT6dIkdW1xJmoBV7n
MIx97K3MhnbuVokWpZ3Wj43JQRYHBMmRTcdx7yGvir8iBkr+JhXZF7F9+0xKIe/4
ru6If0HOamxtSI4xBJ2t2uxmT2F4RVtIJwCPQO3I6oA5yadNuLc1gb3dB5i7WQCJ
3kyi7OVGFiW74i48ouFksbhI22/hRjSJUY12HzsegSthxfpQvVOH07s34yJlIQvk
PlSiSqpOiWVKV9MVSLJBLoxS/7fVIhdCSDTrCxYY+MJDwYhLn94dfz9OJ/dzIE/N
c4s5Oqieb9+p7gW8Ftki+a2JMk52slRq9qVOSEtJYS1XaUbPrkVafUhnmvHywv6W
owBko2anQchupAd9mfBoOuj9U4HLqccyKNx9YLSVpQ/Fr4/IOqb3CxB8LC9AxhGa
U7GIwTJr81Ptnj3lAIi7
=QQ2H
-----END PGP SIGNATURE-----

--hiiboxguzdlnzlgo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
