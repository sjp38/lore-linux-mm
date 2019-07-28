Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F038CC433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 23:51:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85A382085A
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 23:51:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="LUBMGnGh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85A382085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5DA98E0003; Sun, 28 Jul 2019 19:51:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE66D8E0002; Sun, 28 Jul 2019 19:51:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 987AB8E0003; Sun, 28 Jul 2019 19:51:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 606648E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 19:51:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n3so27167084pgh.12
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 16:51:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=YJlc/5wvWuW8+1fJ7QZ0mHgKXf0i9fMMDgbkXeOrnO0=;
        b=ZunU2tUJoI5hLPrePP57WcOthNDdf3dF10TAI+/RVuKBryERnsqBdsk/NFtEoYdFI2
         ZyL1ymbTg4FGdhN6gRDlY7SmxCuZZJiptmK2nt8sTB0C6TgYkXKkN4YsH6H8rW+lziuk
         yoJ+gOSc8ny012UZ5DlB9GGwiz3UlsBDXPb58/s1Fux0u+/Ju3ZIEAXaMfnYBAwXckeN
         lA1lrfMwJHVgULccEnzyE5Lg7NnC4YZjycZ+J1dlA24yd7ff2EArT9reyr073itZFbbA
         ZB26KUXEEleNFAl15sQfMGdlb/DphEpKZ0ZGse1fAsZNMvZOIwU7K4kzHW7qxm/xUEwv
         VHsw==
X-Gm-Message-State: APjAAAX8TTVU6Rg1yVjh0MLFDk7X9VMSdWHrtY6GoyUMgDhPWrHcDCPy
	aY51Y9HNfNhFSPFz+h3tjaSbVle3a4UK5YwVJngiLkUvZvAzuJsVJqepVmltaLbGW8A7Lu7UdxU
	E/RClaX6/xSL5qKjUWx01U38ZalxYpxdjjTS4FyPZIt5wQm3CQS/DZ9X5qeRjANCX2Q==
X-Received: by 2002:a62:cf07:: with SMTP id b7mr33838605pfg.217.1564357887930;
        Sun, 28 Jul 2019 16:51:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTfHOMUA/M1OzkZA3EZLpApFtA4XJGZK80qENmyp3ZqYctLg0+gGNDgU0bKKx/IDwanjPk
X-Received: by 2002:a62:cf07:: with SMTP id b7mr33838569pfg.217.1564357887117;
        Sun, 28 Jul 2019 16:51:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564357887; cv=none;
        d=google.com; s=arc-20160816;
        b=u/FEuNr7TtBjFVONv1YM8qZR3Qv05QG4/1Tnsa0siOR1C34rFIhCaxFIfB+ga3/n9q
         rZnJA1+0+vec0QrmmAfxLc9cn7Umh9Kbi9JqOK+nIhwKCKSAhL5NvftaXvEs4YNWV+14
         KWBhqa9ckaibkeZDp5xdrhe+zSp1oif3DDzdIVCmgP3TIbpV03CjLiM/OijUk/9Q9miA
         EYHLo6flBAaVVF+tN1StG4RjD+0oM6ONffXn77LOZwLl0dbrgJpMG/AVyYsCFl9pQNu7
         1FtzZ3h1YtmkmzXdTkS5m2MOa0VkHUlKWD9/+sU2K96aX4gY0e+iTuXqNgJMnDBL0cKL
         6bbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=YJlc/5wvWuW8+1fJ7QZ0mHgKXf0i9fMMDgbkXeOrnO0=;
        b=EtueI4dRYxs7jEI6SHM5yTd00So1v5/6JUwt6sf431KpTRgvKlaWi03oe0zA9R7vR5
         3mUsNUUQ1jNtlYCE20UP9GmSJSVd6Ae0H5/mNXjhSheSIoKukB8fHSo+EXtAgpBbV+Te
         OfH6WC1Ppurt9UxzQrCAw0fRffSghhOU51AhkF8+XD2sulWOoqJzXr703MJcxd9BZ8FT
         HmX3AqpeGxpI7b2peMYEuT1cjZI5n1iiCQK+ChkDkylbcLmQHBydEoorDcOSp1vMEuQi
         255y7C3c8wV3d5Nu/bY+YxBFl8oqKQD0Plp5ZlCOuNWRdG1RrMd9p5bh3wT7obQfqdJS
         dYQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=LUBMGnGh;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id h69si26131218pge.543.2019.07.28.16.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 28 Jul 2019 16:51:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=LUBMGnGh;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45xfjQ2Q0wz9sBt;
	Mon, 29 Jul 2019 09:51:22 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1564357883;
	bh=+Sm3w908JcE82ssAs1nSzuDW2v9mYsOQgWyC71ct+r4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=LUBMGnGhZiyd6A2n9SjLJbgB1fX/qq4quPY2rR4fx4UmSVL1hnCt2zwGGwF1vmeCY
	 IIpWjYeDbHhu4LjuA2lXj32tosi0nKjOQOQYvBZk+mHFcLDWe1S+H1MCo8U8F8PnbT
	 yPPrQW5jkM8pM6Xn5d4nDh4KkpRRL1c2rViyharlscFJF47Ftytd2S1VdaU/FjgzUh
	 NRhCPjtu9+cfX/+XW8X12/JlWrmBRUZtfj+m/op4PeC1ycKzwK9u0qbsLKnJfp/4mm
	 D1OfW6lxvooS3/QAIt4AZiaq9Kensk+7vVygKTDuccbp1TGTxtdVgyY0SbcLRdsz/q
	 XhHyx1knsyguA==
Date: Mon, 29 Jul 2019 09:51:21 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Chancellor
 <natechancellor@gmail.com>, Randy Dunlap <rdunlap@infradead.org>,
 broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
Message-ID: <20190729095121.080c1a93@canb.auug.org.au>
In-Reply-To: <20190727101608.GA1740@chrisdown.name>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
	<4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
	<20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
	<20190727034205.GA10843@archlinux-threadripper>
	<20190726211952.757a63db5271d516faa7eaac@linux-foundation.org>
	<20190727101608.GA1740@chrisdown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/zy3Q_OmUUHqfTfaZG9i6x+B";
 protocol="application/pgp-signature"; micalg=pgp-sha256
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/zy3Q_OmUUHqfTfaZG9i6x+B
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Sat, 27 Jul 2019 11:16:08 +0100 Chris Down <chris@chrisdown.name> wrote:
>
> u64 division: truly the gift that keeps on giving. Thanks Andrew for foll=
owing=20
> up on these.
>=20
> Andrew Morton writes:
> >Ah.
> >
> >It's rather unclear why that u64 cast is there anyway.  We're dealing
> >with ulongs all over this code.  The below will suffice. =20
>=20
> This place in particular uses u64 to make sure we don't overflow when lef=
t=20
> shifting, since the numbers can get pretty big (and that's somewhat neede=
d due=20
> to the need for high precision when calculating the penalty jiffies). It'=
s ok=20
> if the output after division is an unsigned long, just the intermediate s=
teps=20
> need to have enough precision.
>=20
> >Chris, please take a look?
> >
> >--- a/mm/memcontrol.c~mm-throttle-allocators-when-failing-reclaim-over-m=
emoryhigh-fix-fix-fix
> >+++ a/mm/memcontrol.c
> >@@ -2415,7 +2415,7 @@ void mem_cgroup_handle_over_high(void)
> > 	clamped_high =3D max(high, 1UL);
> >
> > 	overage =3D (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
> >-	do_div(overage, clamped_high);
> >+	overage /=3D clamped_high; =20
>=20
> I think this isn't going to work because left shifting by=20
> MEMCG_DELAY_PRECISION_SHIFT can make the number bigger than ULONG_MAX, wh=
ich=20
> may cause wraparound -- we need to retain the u64 until we divide.
>=20
> Maybe div_u64 will satisfy both ARM and i386? ie.
>=20
> diff --git mm/memcontrol.c mm/memcontrol.c
> index 5c7b9facb0eb..e12a47e96154 100644
> --- mm/memcontrol.c
> +++ mm/memcontrol.c
> @@ -2419,8 +2419,8 @@ void mem_cgroup_handle_over_high(void)
>          */
>         clamped_high =3D max(high, 1UL);
> =20
> -       overage =3D (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
> -       do_div(overage, clamped_high);
> +       overage =3D div_u64((u64)(usage - high) << MEMCG_DELAY_PRECISION_=
SHIFT,
> +                         clamped_high);
> =20
>         penalty_jiffies =3D ((u64)overage * overage * HZ)
>                 >> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHI=
FT); =20

I have applied this to the akpm-current tree in linux-next today.

--=20
Cheers,
Stephen Rothwell

--Sig_/zy3Q_OmUUHqfTfaZG9i6x+B
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0+NPkACgkQAVBC80lX
0GwSggf/R3ZZuH5LliVhgCqbaBSFe93KVSxKonReOK3mTFha+qmnk8vOnjMxHn6E
LnMnA3mI7jJZw/uHTSE/ccUfWIGgJ/nWKU8M2iCuVQwChcocbVaf6TTViNwSZRAy
0hgehpDyAN/LuS8hPxNHre02xDtx4faKRkUUPLUuFC6wXycQ6UoLFoccYNQWKbuB
Xdm5vGFxSwgNkwi/wGWZnkikoBMIOseFvqDP7SevW2NAQdST9LIoXY2t5RXTcNDh
O6E3TpOOXH+GP00uphn+21GLF4AGZLgajZrTdv2v/pkzSfW1qI/hdfkuHb1bOCnx
SFymgmdpe6PfoqnBr01hSGHc22TskQ==
=DFTr
-----END PGP SIGNATURE-----

--Sig_/zy3Q_OmUUHqfTfaZG9i6x+B--

