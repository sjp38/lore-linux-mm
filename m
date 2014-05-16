Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4D26B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 13:45:25 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so1079808igq.16
        for <linux-mm@kvack.org>; Fri, 16 May 2014 10:45:24 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id k17si3318720icg.22.2014.05.16.10.45.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 10:45:24 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id hn18so1104672igb.0
        for <linux-mm@kvack.org>; Fri, 16 May 2014 10:45:24 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to non-zero value
In-Reply-To: <5375C619.8010501@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE> <5375C619.8010501@lge.com>
Date: Fri, 16 May 2014 10:45:12 -0700
Message-ID: <xa1tppjdfwif.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, May 16 2014, Gioh Kim wrote:
> If CMA_SIZE_MBYTES is allowed to be zero, there should be defense code
> to check CMA is initlaized correctly. And atomic_pool initialization
> should be done by __alloc_remap_buffer instead of
> __alloc_from_contiguous if __alloc_from_contiguous is failed.

Agreed, and this is the correct fix.

> IMPO, it is more simple and powerful to restrict CMA_SIZE_MBYTES_MAX
> configuration to be larger than zero.

No, because it makes it impossible to have CMA disabled by default and
only enabled if command line argument is given.

Furthermore, your patch does *not* guarantee CMA region to always be
allocated.  If CMA_SIZE_SEL_PERCENTAGE is selected for instance.  Or if
user explicitly passes 0 on command line.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJTdk6oAAoJECBgQBJQdR/0/uAP/iy4hKtOCEcIenjryq8Y8a6e
A8qqXcLu0Ms9x0Pj6ooWAZiEwgyXMZaTv7ykH3JRGW6JDD4oHLwkCO5ZHXrhT1mf
pPWIhdVJNJsFL8YBEoIWzRzdMFyXsPhezn79dCR4mX/mIMGiZtKEbNc8uTSNJozS
yF0ZPGeevPWBgb5bJVh0ijDm26zyXIXk/aRxHCX5C9XgIS7aZhbKMmG2J2X97NU/
eyuQCPhzzfXKzcDzpZUYm2HhZDaJ/CQKOGQDwTDPVsuktOPeKu5T94+j5cFK9rKW
NG/uTXDWA2B9DsC/OIcmSf/IFFHojWr2i7zaMPK4kXN6Hd+MAr9WNm+aslo8df+J
F8Y2y9Gbu2ZQjBbB2R3Ecz4AJUDZgquOwSG54N+6QZuY+aMKoL3sc7kI+q12mZKS
m2DjnEp6uUPsYo2RUaOotqjHBjiKlfLN6tBpxsP0BFRYyf/KCs7FGG/NS9g5xcU+
fI0h4AXIiA8g+bP1lmcv7BRFefKRZsQLYRuNoFFvzAqz0wmQ5tHpZylE6sEbpHzm
d2dDlVizFPF9QEnLLMFGfOYUZrLLan3jmlCy5+dMKxKF2AdOKFYIrpexb5Io+jRp
kabi/5LDR8ISiULgiQ9NDZyGTCXTmsvkvGQTuYyJhS+bBrQtrlVVL8w5Qx6/WSU1
l9Se161WbizexGWJds28
=oIPD
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
