Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 879186B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 00:13:07 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1704842qwf.44
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 21:13:10 -0700 (PDT)
Message-ID: <4AB1B752.4010505@gmail.com>
Date: Thu, 17 Sep 2009 00:13:06 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <20090917035717.GB3088@redhat.com>
In-Reply-To: <20090917035717.GB3088@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEC75824AD85A44F4912F87A4"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEC75824AD85A44F4912F87A4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Wed, Sep 16, 2009 at 10:10:55AM -0400, Gregory Haskins wrote:
>>> There is no role reversal.
>> So if I have virtio-blk driver running on the x86 and vhost-blk device=

>> running on the ppc board, I can use the ppc board as a block-device.
>> What if I really wanted to go the other way?
>=20
> It seems ppc is the only one that can initiate DMA to an arbitrary
> address, so you can't do this really, or you can by tunneling each
> request back to ppc, or doing an extra data copy, but it's unlikely to
> work well.
>=20
> The limitation comes from hardware, not from the API we use.

Understood, but presumably it can be exposed as a sub-function of the
ppc's board's register file as a DMA-controller service to the x86.
This would fall into the "tunnel requests back" category you mention
above, though I think "tunnel" implies a heavier protocol than it would
actually require.  This would look more like a PIO cycle to a DMA
controller than some higher layer protocol.

You would then utilize that DMA service inside the memctx, and it the
rest of vbus would work transparently with the existing devices/drivers.

I do agree it would require some benchmarking to determine its
feasibility, which is why I was careful to say things like "may work"
;).  I also do not even know if its possible to expose the service this
way on his system.  If this design is not possible or performs poorly, I
admit vbus is just as hosed as vhost in regard to the "role correction"
benefit.

Kind Regards,
-Greg


--------------enigEC75824AD85A44F4912F87A4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqxt1IACgkQP5K2CMvXmqFcBACdEdK6dMDD1cgvHnfb47PWv9rw
arAAn0YoNmyNwDHyndyfBYpZXKHxTcPt
=/ezZ
-----END PGP SIGNATURE-----

--------------enigEC75824AD85A44F4912F87A4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
