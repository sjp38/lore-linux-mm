Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 867586B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 14:15:47 -0500 (EST)
Received: by qw-out-1920.google.com with SMTP id 5so1503780qwc.44
        for <linux-mm@kvack.org>; Wed, 04 Nov 2009 11:15:45 -0800 (PST)
Message-ID: <4AF1D2DE.10705@gmail.com>
Date: Wed, 04 Nov 2009 14:15:42 -0500
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv8 0/3] vhost: a kernel-level virtio server
References: <20091104155234.GA32673@redhat.com> <4AF1A587.8000509@gmail.com> <20091104162339.GA311@redhat.com>
In-Reply-To: <20091104162339.GA311@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE41C0DE2FBFBF3E83786E82A"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE41C0DE2FBFBF3E83786E82A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Wed, Nov 04, 2009 at 11:02:15AM -0500, Gregory Haskins wrote:
>> Michael S. Tsirkin wrote:
>>> Ok, I think I've addressed all comments so far here.
>>> Rusty, I'd like this to go into linux-next, through your tree, and
>>> hopefully 2.6.33.  What do you think?
>> I think the benchmark data is a prerequisite for merge consideration, =
IMO.
>=20
> Shirley Ma was kind enough to send me some measurement results showing
> how kernel level acceleration helps speed up you can find them here:
> http://www.linux-kvm.org/page/VhostNet

Thanks for the pointers.  I will roll your latest v8 code into our test
matrix.  What kernel/qemu trees do they apply to?

-Greg


--------------enigE41C0DE2FBFBF3E83786E82A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrx0t4ACgkQP5K2CMvXmqFRbgCeLpbxRPIlSPlPG7HtOurzxEQp
lWUAnjOvhcZm8LOVA2vlgoLaN/wgPdzQ
=JO1s
-----END PGP SIGNATURE-----

--------------enigE41C0DE2FBFBF3E83786E82A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
