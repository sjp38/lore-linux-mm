Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id A1C9A6B0036
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:45:40 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ij19so5594214vcb.28
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:45:40 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id py5si2434987pbc.443.2014.05.09.08.45.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:45:40 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so3871453pde.29
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:45:39 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma reserved memory when not used
In-Reply-To: <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Fri, 09 May 2014 08:45:32 -0700
Message-ID: <xa1t4n0zx8f7.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, May 07 2014, Joonsoo Kim wrote:
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

The code looks good to me, but I don't feel competent on whether the
approach is beneficial or not.  Still:

Acked-by: Michal Nazarewicz <mina86@mina86.com>


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

iQIbBAEBAgAGBQJTbPgcAAoJECBgQBJQdR/0V5EP9iwYwqxiwv9ZPYqFtCjjAsHH
tJomWa/nlEKJ+eVoTwFT2FjpORmux2MHNDCWL+ncpV4Gh3SODbstkiRhJNksiOsz
CKrc/amtefoiCkZOLf478Mn845t4a9TitUN3fAPqG4/iPulf1alelymFqaSiTU+I
wV5JaQK5KWUnUADR/5UzMCEG1pgyu9SbIHYM2pKljbtFDNrrcE+h10UFepUgiNda
onZvB002cdV4KR3ZA1Dw7UcMarL/gSL1GbWiqHuQz0Za2yoPZNtWJtuBoYBfNjfq
Nlq0aIrKmx0viXfC4XkdRIJ0lJkEaWz560exmeEXWrO3egd3TtbYjPdZ5nheDUBZ
21ZkTTSYggR33oIasTGiAGFrJNDdX2TebAvulC1vIYZ+7wP53iwHNBQqU6UkpPw+
0PrLQa1a7THDpoalRkfBCC+HBHBwJvsSGHYlgSvUA/b0EdzuI9CN29Ht+lC/kDqg
vCJiO0yykygOaj/JATdP/kNnmF7KhRAJhUc2HQgrGCQ6wpyQ5Tlk8vtL9OUdaH7G
W8VnqdRTU39S3j/1YXpJCjOxNr7m5mC6hl9pSkBaWzQ0x/bBi21jWiHdOPNWQnxK
Qb+DpilW5ZoSmULo5dwyXIbjVxdoUKJuF9JotBoSP6tDppvXv2LD0a7PoN4oYN6l
FEtcIJ2A1XPixQOfVFk=
=4Tff
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
