Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 79A7682F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 20:36:37 -0500 (EST)
Received: by mail-qk0-f175.google.com with SMTP id s68so62939748qkh.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:36:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a68si31954123qhc.73.2016.02.22.17.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 17:36:36 -0800 (PST)
Message-ID: <1456191393.7716.28.camel@redhat.com>
Subject: Re: [PATCH v2] mm: scale kswapd watermarks in proportion to memory
From: Rik van Riel <riel@redhat.com>
Date: Mon, 22 Feb 2016 20:36:33 -0500
In-Reply-To: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
References: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-oJed4wjTczPUNgfxHokO"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


--=-oJed4wjTczPUNgfxHokO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-22 at 15:33 -0800, Johannes Weiner wrote:

> Beyond 1G of memory, this will produce bigger watermark steps than=20

Is that supposed to be beyond 16GB?

> the
> current formula in default settings. Ensure that the new formula
> never
> chooses steps smaller than that, i.e. 25% of the emergency reserve.
>=20
> On a 140G machine, this raises the default watermark steps - the
> distance between min and low, and low and high - from 16M to 143M.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.


--=-oJed4wjTczPUNgfxHokO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWy7eiAAoJEM553pKExN6DOmsH/3xxiMynm9KxGOJM99uTCgEK
nxwvVzKu7V3G5pnsPQZd55m4AlHGLTbLmLHcx1X1et2u+KYgKJevWPIXXCzP+aHk
1+FJGTN+/4jN0LNVFjfKka3iz6eJsnwefEAJtXoskRXUyKDMgaYfDq0PfVIg0y1W
qPyxR0GXuGe/ltZ8UuGPBYSkQ5JxK0mCS9UGBAp9EgmXCKNVv8H76DyBpxb2SlVs
dQZWKrKDA3FQmeOKFKeVMGPGeBT+036k0DsqOvzyaNjuLu0rhUw72KNcziGnbtzZ
O4di6hA6ffEd2Q2T28e8U/ErTKUNCxfECmLMk261whGqCcXmbT9GpM/UcY6S1+s=
=mkJz
-----END PGP SIGNATURE-----

--=-oJed4wjTczPUNgfxHokO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
