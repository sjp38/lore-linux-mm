Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 59A5B6B0062
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 11:02:24 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 3so1429041eyh.18
        for <linux-mm@kvack.org>; Wed, 04 Nov 2009 08:02:21 -0800 (PST)
Message-ID: <4AF1A587.8000509@gmail.com>
Date: Wed, 04 Nov 2009 11:02:15 -0500
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv8 0/3] vhost: a kernel-level virtio server
References: <20091104155234.GA32673@redhat.com>
In-Reply-To: <20091104155234.GA32673@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9CBB576151305611F6CF6CC2"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9CBB576151305611F6CF6CC2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> Ok, I think I've addressed all comments so far here.
> Rusty, I'd like this to go into linux-next, through your tree, and
> hopefully 2.6.33.  What do you think?

I think the benchmark data is a prerequisite for merge consideration, IMO=
=2E

Do you have anything for us to look at?  I think comparison that show
the following are of interest:

throughput (e.g. netperf::TCP_STREAM): guest->host, guest->host->guest,
guest->host->remote, host->remote, remote->host->guest

latency (e.g. netperf::UDP_RR): same conditions as throughput

cpu-utilization

others?

Ideally, this should be at least between upstream virtio and vhost.
Bonus points if you include venet as well.

Kind regards,
-Greg


--------------enig9CBB576151305611F6CF6CC2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrxpYcACgkQP5K2CMvXmqHHKQCfX0c8WoojuJe1A+eFFzu9twpU
PEkAn2bUMmeK9n8AfgWItG+bCqzjqtDQ
=6kXy
-----END PGP SIGNATURE-----

--------------enig9CBB576151305611F6CF6CC2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
