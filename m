Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D7CC46B0055
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 15:14:36 -0400 (EDT)
Received: by qyk11 with SMTP id 11so2702312qyk.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:14:40 -0700 (PDT)
Message-ID: <4AAE961B.6020509@gmail.com>
Date: Mon, 14 Sep 2009 15:14:35 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <cover.1251388414.git.mst@redhat.com> <20090827160750.GD23722@redhat.com> <20090903183945.GF28651@ovro.caltech.edu> <20090907101537.GH3031@redhat.com> <20090908172035.GB319@ovro.caltech.edu> <4AAA7415.5080204@gmail.com> <20090913120140.GA31218@redhat.com> <4AAE6A97.7090808@gmail.com> <20090914164750.GB3745@redhat.com>
In-Reply-To: <20090914164750.GB3745@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2959D78D936A954B1F0C2FB2"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2959D78D936A954B1F0C2FB2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Mon, Sep 14, 2009 at 12:08:55PM -0400, Gregory Haskins wrote:
>> For Ira's example, the addresses would represent a physical address on=

>> the PCI boards, and would follow any kind of relevant rules for
>> converting a "GPA" to a host accessible address (even if indirectly, v=
ia
>> a dma controller).
>=20
> I don't think limiting addresses to PCI physical addresses will work
> well.

The only "limit" is imposed by the memctx.  If a given context needs to
meet certain requirements beyond PCI physical addresses, it would
presumably be designed that way.


>  From what I rememeber, Ira's x86 can not initiate burst
> transactions on PCI, and it's the ppc that initiates all DMA.

The only requirement is that the "guest" "owns" the memory.  IOW: As
with virtio/vhost, the guest can access the pointers in the ring
directly but the host must pass through a translation function.

Your translation is direct: you use a slots/hva scheme.  My translation
is abstracted, which means it can support slots/hva (such as in
alacrityvm) or some other scheme as long as the general model of "guest
owned" holds true.

>=20
>>>  But we can't let the guest specify physical addresses.
>> Agreed.  Neither your proposal nor mine operate this way afaict.
>=20
> But this seems to be what Ira needs.

So what he could do then is implement the memctx to integrate with the
ppc side dma controller.  E.g. "translation" in his box means a protocol
from the x86 to the ppc to initiate the dma cycle.  This could be
exposed as a dma facility in the register file of the ppc boards, for
instance.

To reiterate, as long as the model is such that the ppc boards are
considered the "owner" (direct access, no translation needed) I believe
it will work.  If the pointers are expected to be owned by the host,
then my model doesn't work well either.

Kind Regards,
-Greg


--------------enig2959D78D936A954B1F0C2FB2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqulhsACgkQP5K2CMvXmqHsYACePYzh0H3oY5W3aAc6pFFp4w3u
tYEAnRNmpU/44+9P++MVTtjbqreGPiiM
=J8am
-----END PGP SIGNATURE-----

--------------enig2959D78D936A954B1F0C2FB2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
