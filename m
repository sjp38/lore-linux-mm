Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC836B025F
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:24:38 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w63so9130937qkd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:24:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o25si1256229qta.404.2017.10.03.08.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:24:37 -0700 (PDT)
Message-ID: <1507044274.10046.20.camel@redhat.com>
Subject: Re: [PATCH] mm: remove unused pgdat->inactive_ratio
From: Rik van Riel <riel@redhat.com>
Date: Tue, 03 Oct 2017 11:24:34 -0400
In-Reply-To: <20171003152611.27483-1-aryabinin@virtuozzo.com>
References: <20171003152611.27483-1-aryabinin@virtuozzo.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-eQR8LS96VfuSBVNBG/RJ"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-eQR8LS96VfuSBVNBG/RJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-10-03 at 18:26 +0300, Andrey Ryabinin wrote:
> Since commit 59dc76b0d4df ("mm: vmscan: reduce size of inactive file
> list")
> 'pgdat->inactive_ratio' is not used, except for printing
> "node_inactive_ratio: 0" in /proc/zoneinfo output.
>=20
> Remove it.
>=20
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-eQR8LS96VfuSBVNBG/RJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZ06uyAAoJEM553pKExN6DrkEH/iTTErr91ta3XDQPhi8cjslM
FMxLNDhHvsC3K6l67+VPNdO3YPW0Ch46ZvXYFrFz+VwOgkrY9F6QcUSYosBYs2qv
ZwBULXoZdt9tPAdmoPQPgvcslrcHDkOolaRLXY4HzYVXLlvNyLHpsLbC7VZGnlkp
D2D63t+MyhF+VWuZb7XFdqJbwPj1nkJkwscV46GNTmOqeKDgCwWlxI486XKx30wH
8rtyIXfgGpbILwqF0fSDYBONs0MiVfieu2VPc28URg6G0XrFtG31ghyxeYjNGlkY
ThgN56EQhiU7zmufwVqUEd3U5aqRUelJCajJdDSbjpLKexUVSV/gZwwrK/uw//o=
=yUFm
-----END PGP SIGNATURE-----

--=-eQR8LS96VfuSBVNBG/RJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
