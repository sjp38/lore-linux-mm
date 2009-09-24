Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 692B76B005D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 14:04:43 -0400 (EDT)
Received: by fxm2 with SMTP id 2so1610433fxm.4
        for <linux-mm@kvack.org>; Thu, 24 Sep 2009 11:04:39 -0700 (PDT)
Message-ID: <4ABBB4B2.7050404@gmail.com>
Date: Thu, 24 Sep 2009 14:04:34 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABB27B9.4050904@redhat.com>
In-Reply-To: <4ABB27B9.4050904@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDE5D73E043EEC9B7281C9F0D"
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDE5D73E043EEC9B7281C9F0D
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 09/23/2009 10:37 PM, Avi Kivity wrote:
>>
>> Example: feature negotiation.  If it happens in userspace, it's easy
>> to limit what features we expose to the guest.  If it happens in the
>> kernel, we need to add an interface to let the kernel know which
>> features it should expose to the guest.  We also need to add an
>> interface to let userspace know which features were negotiated, if we
>> want to implement live migration.  Something fairly trivial bloats
>> rapidly.
>=20
> btw, we have this issue with kvm reporting cpuid bits to the guest.=20
> Instead of letting kvm talk directly to the hardware and the guest, kvm=

> gets the cpuid bits from the hardware, strips away features it doesn't
> support, exposes that to userspace, and expects userspace to program th=
e
> cpuid bits it wants to expose to the guest (which may be different than=

> what kvm exposed to userspace, and different from guest to guest).
>=20

This issue doesn't exist in the model I am referring to, as these are
all virtual-devices anyway.  See my last reply

-Greg


--------------enigDE5D73E043EEC9B7281C9F0D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkq7tLIACgkQP5K2CMvXmqFsrACfdMqWfjhbcD0aRdM1iWka41vU
lDkAmwWgvAoZNTrMhDRgJ/UlEl0f4Mpo
=5LFr
-----END PGP SIGNATURE-----

--------------enigDE5D73E043EEC9B7281C9F0D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
