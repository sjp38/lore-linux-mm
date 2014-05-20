Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id ACF586B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 21:28:37 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so6597665pbc.0
        for <linux-mm@kvack.org>; Mon, 19 May 2014 18:28:37 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id ny3si9719364pab.230.2014.05.19.18.28.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 18:28:36 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id r10so56758pdi.5
        for <linux-mm@kvack.org>; Mon, 19 May 2014 18:28:36 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to non-zero value
In-Reply-To: <537AA6C7.1040506@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE> <5375C619.8010501@lge.com> <xa1tppjdfwif.fsf@mina86.com> <537962A0.4090600@lge.com> <20140519055527.GA24099@js1304-P5Q-DELUXE> <xa1td2f91qw5.fsf@mina86.com> <537AA6C7.1040506@lge.com>
Date: Mon, 19 May 2014 15:28:24 -1000
Message-ID: <xa1tzjiddyrr.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, May 19 2014, Gioh Kim wrote:
> If CMA option is not selected, __alloc_from_contiguous would not be
> called.  We don't need to the fallback allocation.
>
> And if CMA option is selected and initialized correctly,
> the cma allocation can fail in case of no-CMA-memory situation.
> I thinks in that case we don't need to the fallback allocation also,
> because it is normal case.
>
> Therefore I think the restriction of CMA size option and make CMA work
> can cover every cases.

Wait, you just wrote that if CMA is not initialised correctly, it's fine
for atomic pool initialisation to fail, but if CMA size is initialised
correctly but too small, this is somehow worse situation?  I'm a bit
confused to be honest.

IMO, cma=3D0 command line argument should be supported, as should having
the default CMA size zero.  If CMA size is set to zero, kernel should
behave as if CMA was not enabled at compile time.

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

iQIcBAEBAgAGBQJTeq+5AAoJECBgQBJQdR/0Ns4P/2+MSDCVhcRh8a2OpEG35FsZ
MY48W6w7LnXneI+SS2/Bx3hHbK4PDuF6DViY/thZ0VYEZ3rg0iaD4v8545LRWE5Z
0GUnjPy9/iPX1jJMnhHJChfYD0D3/l6j+io9TcaBDnsTm+i4zY4Y7R2DyPYZIYDA
RRp1JxkCdcVJ3zF6EqM/9hWPZbrrB6WYB46Ig9lG3IBGUsVdNR3TmAhdwx49IAp3
BPWGJIEKji0HHC0mnvgEzf822bwZc2w1DqpzarJhUYEuxvOyqw3E29mCjNwS9ME4
8aIqWlPka1rqTPylLrspz+P0rFfovag4SHVVLUSqOLvvSgUAqDh/20L9j7+qinmB
PyhQLlH5s38n7cfVPn/DKSB1u8Stpjgen/aydHqDHIiHg/Ng6h9Eb3IZoNMkMAIA
jmpAm3zShgkZJNhkCxwHkWn+mUqo3E3o8cmxE6/b2L0VdO06KIzXZ6jsR4Biy/1s
HI/FocpbzbjHbN+PqpJwgmWOn6ih5+CXPXYaVT20hban5v4jPffor5LbhSStWAeE
K7lYCtuLr6APwB/8/TOwzoKNdLicynZd2s0xLw407RTBtr/MF6sGH2p2rcRnKctB
dOsFd7P1jEzPbRM9AtDlNpYBaImiRNNs2nubEEFC+11ciZrs18PEZ7K/ICJQGO/p
0FSiK86mX2eIZFAgZRj/
=Th+9
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
