Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1CF46B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:53:27 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id k36so14022691otb.3
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 11:53:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o206si1536050oih.248.2017.06.15.11.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 11:53:27 -0700 (PDT)
Message-ID: <1497552803.20270.96.camel@redhat.com>
Subject: Re: [PATCH v2 01/10] x86/ldt: Simplify LDT switching logic
From: Rik van Riel <riel@redhat.com>
Date: Thu, 15 Jun 2017 14:53:23 -0400
In-Reply-To: <c1d005d9608fa44ef124910ee02765edbcb3dd99.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
	 <c1d005d9608fa44ef124910ee02765edbcb3dd99.1497415951.git.luto@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-38c+EeEUFFjuMvvBynlh"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


--=-38c+EeEUFFjuMvvBynlh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-06-13 at 21:56 -0700, Andy Lutomirski wrote:

> Simplify the code to update LDTR if either the previous or the next
> mm has an LDT, i.e. effectively restore the historical logic..
> While we're at it, clean up the code by moving all the ifdeffery to
> a header where it belongs.
>=20
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-38c+EeEUFFjuMvvBynlh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZQtejAAoJEM553pKExN6DzC0H/RAW+X88/fAzHWuc6tjYGuxM
ybXi2RTkLPzZF9W1zD1peU65RkGXww4oWfwvwRdrumPfLNrAlciPR8MlffdPEGNc
DuTviKThJJkYBI4Ellc472g2k8iCUDI8WxE9TRC2zC9/ZN6AXMJVg6rUn1RnYpRx
zX4DQw7XPK5u4/QWv4ULoPVk4AS+68G+P1IaJ5ZLI9Vy1aMqDL6lYbigHcHu42tb
QngvjbuA7RebfRSKk5zFOWAphbqW+hNTRhldLIyStmtKrPcylbyEq4uYZFUhKSlm
imW+eUL/fegk49N9AzAsqty1a+jzlfo1zq1cA3p3F83sPn5txY3+rCo/dgATX+E=
=OmmN
-----END PGP SIGNATURE-----

--=-38c+EeEUFFjuMvvBynlh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
