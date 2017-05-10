Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA1A183204
	for <linux-mm@kvack.org>; Tue,  9 May 2017 22:38:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o25so15029618pgc.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:38:14 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id y13si1639657pgc.90.2017.05.09.19.38.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 19:38:13 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 64so2200676pgb.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 19:38:13 -0700 (PDT)
Date: Wed, 10 May 2017 10:38:13 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: fix spelling error
Message-ID: <20170510023813.GA8480@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170403161655.5081-1-haolee.swjtu@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Content-Disposition: inline
In-Reply-To: <20170403161655.5081-1-haolee.swjtu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hao Lee <haolee.swjtu@gmail.com>
Cc: akpm@linux-foundation.org, alexander.h.duyck@intel.com, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 04, 2017 at 12:16:55AM +0800, Hao Lee wrote:
>Fix variable name error in comments. No code changes.
>
>Signed-off-by: Hao Lee <haolee.swjtu@gmail.com>
>---
> include/linux/gfp.h | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>index db373b9..ff3d651 100644
>--- a/include/linux/gfp.h
>+++ b/include/linux/gfp.h
>@@ -297,8 +297,8 @@ static inline bool gfpflags_allow_blocking(const gfp_t=
 gfp_flags)
>=20
> /*
>  * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
>- * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT l=
ong
>- * and there are 16 of them to cover all possible combinations of
>+ * zone to use given the lowest 4 bits of gfp_t. Entries are GFP_ZONES_SH=
IFT
>+ * bits long and there are 16 of them to cover all possible combinations =
of
>  * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM.
>  *
>  * The zone fallback order is MOVABLE=3D>HIGHMEM=3D>NORMAL=3D>DMA32=3D>DM=
A.

Looks good to me.

Acked-by: Wei Yang <richard.weiyang@gmail.com>

>--=20
>2.9.3

--=20
Wei Yang
Help you, Help me

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZEn0VAAoJEKcLNpZP5cTdcQUQAIeaoGcQHhsbaoSFKGe+fWro
4daDgpwLQu7AUjFb8YY9s3SjvsJ1RWokFkoZbL/8C0A+cHx6XZZyvNfUK4upEHm4
kwl6orNkDhwJ8D47jHNg/T6qO1trZ4aG+x1T609VsPxsOuxKsg8NSAIE3yTeGAAp
R+zukER/4yOpbZ8bztVLTPFz23X68Fmi0UJV2i6tp7aN0a07EGlrbutGwYlRBSnm
sF4y/p7sxcDRapmxLvUI0Qs/4l9Pl10eMq7rIyi8ql5pSnt+QfaH2rzV/KU2Ns60
8bPjuBzgVsAuyul1vHzO/xgCOh9hSjmoUB0YY6CFzN0DSozmw7W8zduXXuNIRfNG
RLhUIIoUqr05zxE+zvAb54MSLqf2Ysm08seGEyw1ZIrhZulIpZKLeKaf3Pnm/P78
sSovFlkbqg7ld/wCwnnb9gSTguhx896HTopcpZD/qU6J3/xvQGxJArfJl0FQI7sh
cLRENDYW9oRXmkbkn+4wh3DhECZjzcGPbIn3iedBAc46nBKGqTrjOIuXCChyPrjm
cBjoLXnu7B43zp4OUgBMXa9YSjhSE1VHDvPE2odDP3TMi5vKILlVNKhLxde+mFKC
WgBSrqKuNYud/S8rslzF5TtZCzCFK/t3EbqaAvRn0F5gfQZP8HTUf2alhv+nVRq9
YVWTw2tR6quefpogUbYT
=vZxz
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
