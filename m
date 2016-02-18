Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0C4828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 16:05:12 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id b35so46955345qge.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 13:05:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l34si54896235qgf.84.2016.02.18.13.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 13:05:11 -0800 (PST)
Message-ID: <1455829507.15821.69.camel@redhat.com>
Subject: Re: [RFC PATCH] proc: do not include shmem and driver pages in
 /proc/meminfo::Cached
From: Rik van Riel <riel@redhat.com>
Date: Thu, 18 Feb 2016 16:05:07 -0500
In-Reply-To: <1455827801-13082-1-git-send-email-hannes@cmpxchg.org>
References: <1455827801-13082-1-git-send-email-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-cC6pBBNk06APht7w+ZIR"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, kernel-team@fb.com


--=-cC6pBBNk06APht7w+ZIR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-02-18 at 15:36 -0500, Johannes Weiner wrote:
>=C2=A0
> The semantics of Cached including shmem and kernel pages have been
> this way forever, dictated by the single-LRU implementation rather
>=20
They may have been that way forever,
but they have also been confusing to
users forever, so ...

> than optimal semantics. So it's an uncomfortable proposal to change
> it
> now. But what other way to fix this for existing users? What other
> way
> to make the interface more intuitive for future users? And what could
> break by removing it now? I guess somebody who already subtracts
> Shmem
> from Cached.
>=20
> What are your thoughts on this?
>=C2=A0
Reviewed-by: Rik van Riel <riel@redhat.com>

--=C2=A0
All rights reversed

--=-cC6pBBNk06APht7w+ZIR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWxjIDAAoJEM553pKExN6DLeEH/A5r/g6njVnlExdi+7it41gZ
I/nZxkmRzEtVYWGSKoS+i/JItuv38riFB5xK8GwGLPUEQ++OcEh0Zcogv8Pmj8IB
EmzqpyQdpt/GYlopRIXK0DBWS1q2ilJ1xAeUNOT3Mgc3AO/znPv1LJRRbzc/F3xH
O+HA5R6NBsZFnsUIbVTMRcj8THvfXTu7pf/ptw6jrL52HtU+UFBzB3mfExKFdxKy
oEZI8OmV51U/aY5HIEuQts4JhgYQtuYEl4pna8GPVrawh1GHHk2qjvd8i9YEmPXH
HnxQ574+VI90lr2FTEC783V3V4tUEHfta8Ly/yiOyHeThuadhjXmh9M58W8K8aM=
=Bui8
-----END PGP SIGNATURE-----

--=-cC6pBBNk06APht7w+ZIR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
