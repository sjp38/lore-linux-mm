Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5C26A6B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 19:49:39 -0400 (EDT)
Received: by qyk36 with SMTP id 36so3700182qyk.12
        for <linux-mm@kvack.org>; Tue, 11 Aug 2009 16:49:44 -0700 (PDT)
Message-ID: <4A820391.1090404@gmail.com>
Date: Tue, 11 Aug 2009 19:49:37 -0400
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
References: <20090811212743.GA26309@redhat.com>
In-Reply-To: <20090811212743.GA26309@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA223C963729B04B1689E60E6"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA223C963729B04B1689E60E6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> This implements vhost: a kernel-level backend for virtio,
> The main motivation for this work is to reduce virtualization
> overhead for virtio by removing system calls on data path,
> without guest changes. For virtio-net, this removes up to
> 4 system calls per packet: vm exit for kick, reentry for kick,
> iothread wakeup for packet, interrupt injection for packet.
>=20
> Some more detailed description attached to the patch itself.
>=20
> The patches are against 2.6.31-rc4.  I'd like them to go into linux-nex=
t
> and down the road 2.6.32 if possible.  Please comment.

I will add this series to my benchmark run in the next day or so.  Any
specific instructions on how to set it up and run?

Regards,
-Greg


--------------enigA223C963729B04B1689E60E6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqCA5EACgkQP5K2CMvXmqHIvQCfYcoxCyKZvGg3C6EAOrpAEwIH
JmkAnRmvb/eJZIoYNF9JHmDPGvTAdvT/
=dirP
-----END PGP SIGNATURE-----

--------------enigA223C963729B04B1689E60E6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
