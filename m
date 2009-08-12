Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8C0BE6B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 09:51:43 -0400 (EDT)
Received: by yxe14 with SMTP id 14so28525yxe.12
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 06:51:49 -0700 (PDT)
Message-ID: <4A82C8F1.4030703@gmail.com>
Date: Wed, 12 Aug 2009 09:51:45 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
References: <20090811212743.GA26309@redhat.com> <200908121452.01802.arnd@arndb.de> <20090812130612.GC29200@redhat.com> <200908121540.44928.arnd@arndb.de>
In-Reply-To: <200908121540.44928.arnd@arndb.de>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig87A30C9A577D0E621E7B2C9A"
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, Patrick Mullaney <pmullaney@novell.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig87A30C9A577D0E621E7B2C9A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Arnd Bergmann wrote:
> On Wednesday 12 August 2009, Michael S. Tsirkin wrote:
>>> If I understand it correctly, you can at least connect a veth pair
>>> to a bridge, right? Something like
>>>
>>>            veth0 - veth1 - vhost - guest 1=20
>>> eth0 - br0-|
>>>            veth2 - veth3 - vhost - guest 2
>>>           =20
>> Heh, you don't need a bridge in this picture:
>>
>> guest 1 - vhost - veth0 - veth1 - vhost guest 2
>=20
> Sure, but the setup I described is the one that I would expect
> to see in practice because it gives you external connectivity.
>=20
> Measuring two guests communicating over a veth pair is
> interesting for finding the bottlenecks, but of little
> practical relevance.
>=20
> 	Arnd <><

Yeah, this would be the config I would be interested in.

Regards,
-Greg


--------------enig87A30C9A577D0E621E7B2C9A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqCyPEACgkQP5K2CMvXmqHKgwCbBrxhIdqOX31o4APQvc7hWcWt
y0oAn1INe0wEK/9n2tSfeBeMCClGjSXU
=S5BJ
-----END PGP SIGNATURE-----

--------------enig87A30C9A577D0E621E7B2C9A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
