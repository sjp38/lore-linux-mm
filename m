Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E49016B005A
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 12:14:08 -0400 (EDT)
Received: by bwz24 with SMTP id 24so913705bwz.38
        for <linux-mm@kvack.org>; Fri, 11 Sep 2009 09:14:12 -0700 (PDT)
Message-ID: <4AAA774F.2050209@gmail.com>
Date: Fri, 11 Sep 2009 12:14:07 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com>
In-Reply-To: <4AAA7415.5080204@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig82C43E5F2EF2CEB5FEA90C83"
Sender: owner-linux-mm@kvack.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig82C43E5F2EF2CEB5FEA90C83
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Gregory Haskins wrote:

[snip]

>=20
> FWIW: VBUS handles this situation via the "memctx" abstraction.  IOW,
> the memory is not assumed to be a userspace address.  Rather, it is a
> memctx-specific address, which can be userspace, or any other type
> (including hardware, dma-engine, etc).  As long as the memctx knows how=

> to translate it, it will work.
>=20

citations:

Here is a packet import (from the perspective of the host side "venet"
device model, similar to Michaels "vhost")

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Dkernel/vbus/devices/venet-tap.c;h=3Dee091c47f06e9bb84=
87a45e72d493273fe08329f;hb=3Dded8ce2005a85c174ba93ee26f8d67049ef11025#l53=
5

Here is the KVM specific memctx:

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Dkernel/vbus/kvm.c;h=3D56e2c5682a7ca8432c159377b0f7389=
cf34cbc1b;hb=3Dded8ce2005a85c174ba93ee26f8d67049ef11025#l188

and

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Dvirt/kvm/xinterface.c;h=3D0cccb6095ca2a51bad01f7ba213=
7fdd9111b63d3;hb=3Dded8ce2005a85c174ba93ee26f8d67049ef11025#l289

You could alternatively define a memctx for your environment which knows
how to deal with your PPC boards PCI based memory, and the devices would
all "just work".

Kind Regards,
-Greg



--------------enig82C43E5F2EF2CEB5FEA90C83
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqqd08ACgkQP5K2CMvXmqEaqQCfXWSJFQS12SmLB3k+J4WDiEJq
68cAoIjRCya0FvGnWGkZBETyFAe17+a/
=8hCs
-----END PGP SIGNATURE-----

--------------enig82C43E5F2EF2CEB5FEA90C83--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
