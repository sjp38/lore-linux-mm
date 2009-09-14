Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 243E16B004F
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:08:59 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so929078qwf.44
        for <linux-mm@kvack.org>; Mon, 14 Sep 2009 09:09:00 -0700 (PDT)
Message-ID: <4AAE6A97.7090808@gmail.com>
Date: Mon, 14 Sep 2009 12:08:55 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com>
In-Reply-To: <20090913120140.GA31218@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4A7B9E21588ECA3868FA009B"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4A7B9E21588ECA3868FA009B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Fri, Sep 11, 2009 at 12:00:21PM -0400, Gregory Haskins wrote:
>> FWIW: VBUS handles this situation via the "memctx" abstraction.  IOW,
>> the memory is not assumed to be a userspace address.  Rather, it is a
>> memctx-specific address, which can be userspace, or any other type
>> (including hardware, dma-engine, etc).  As long as the memctx knows ho=
w
>> to translate it, it will work.
>=20
> How would permissions be handled?

Same as anything else, really.  Read on for details.

> it's easy to allow an app to pass in virtual addresses in its own addre=
ss space.

Agreed, and this is what I do.

The guest always passes its own physical addresses (using things like
__pa() in linux).  This address passed is memctx specific, but generally
would fall into the category of "virtual-addresses" from the hosts
perspective.

For a KVM/AlacrityVM guest example, the addresses are GPAs, accessed
internally to the context via a gfn_to_hva conversion (you can see this
occuring in the citation links I sent)

For Ira's example, the addresses would represent a physical address on
the PCI boards, and would follow any kind of relevant rules for
converting a "GPA" to a host accessible address (even if indirectly, via
a dma controller).


>  But we can't let the guest specify physical addresses.

Agreed.  Neither your proposal nor mine operate this way afaict.

HTH

Kind Regards,
-Greg


--------------enig4A7B9E21588ECA3868FA009B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkquapcACgkQP5K2CMvXmqEsZQCfcQ2o0HqEYlWAuk3Qckq/ciWq
JrgAn0itJih00Z/pLWaEa7xiy99pwjUj
=Y/uW
-----END PGP SIGNATURE-----

--------------enig4A7B9E21588ECA3868FA009B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
