Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED7396B0262
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 13:06:40 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z142so125952035qkb.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 10:06:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e7si15740433qkj.50.2016.06.13.10.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 10:06:40 -0700 (PDT)
Message-ID: <1465837595.2756.1.camel@redhat.com>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
From: Rik van Riel <riel@redhat.com>
Date: Mon, 13 Jun 2016 13:06:35 -0400
In-Reply-To: <1465804259-29345-4-git-send-email-minchan@kernel.org>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
	 <1465804259-29345-4-git-send-email-minchan@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-m2iURTAO08CwF56PbpE6"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangwoo Park <sangwoo2.park@lge.com>


--=-m2iURTAO08CwF56PbpE6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-13 at 16:50 +0900, Minchan Kim wrote:
> These day, there are many platforms available in the embedded market
> and sometime, they has more hints about workingset than kernel so
> they want to involve memory management more heavily like android's
> lowmemory killer and ashmem or user-daemon with lowmemory notifier.
>=20
> This patch adds add new method for userspace to manage memory
> efficiently via knob "/proc/<pid>/reclaim" so platform can reclaim
> any process anytime.
>=20

Could it make sense to invoke this automatically,
perhaps from the Android low memory killer code?

--=20
All Rights Reversed.


--=-m2iURTAO08CwF56PbpE6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXXugbAAoJEM553pKExN6DmhkH/0WhVg67iaMCy0J11ajkOorR
b5aeC1XEir3OHigTCKlKMPPK4wW8l0ZjxsTNNtRQRVklSWL2wPXc/V03BlnGEKUF
z2d7llNTowcu/KHRXKOtnM6ktDCLXyWfxHFAPMiQ3twAW6+RgZlV1lUlZ0k+5FCv
I/+5QyEW54gJ6fln60xmFovRgOU/XzmqL2tNMUNY9uwxVimaq1WlT3yU5Vlgmi2u
BaOOgkQlzI/v9YO7yMHfrnsIUFXBjqS1EoLvrkLt82gieKfH3W4GfQqowXJARup9
w8Ws+ajVou0UWh3WqOc9YAF1eqp1YbNU5BNfVxmaVAj5YpB5WN20NKuBTTQ1pvU=
=vW3k
-----END PGP SIGNATURE-----

--=-m2iURTAO08CwF56PbpE6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
