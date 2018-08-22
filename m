Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 343626B269C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 18:11:17 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a70-v6so2907834qkb.16
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 15:11:17 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id u32-v6si2915521qth.220.2018.08.22.15.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 15:11:14 -0700 (PDT)
Message-ID: <15474e3aa44fe9f67b6fa6ddb67ff8fc0e6831ad.camel@surriel.com>
Subject: Re: [PATCH 1/4] x86/mm/tlb: Revert the recent lazy TLB patches
From: Rik van Riel <riel@surriel.com>
Date: Wed, 22 Aug 2018 18:11:02 -0400
In-Reply-To: <CA+55aFw6bBFnV__JZnzh0ZCSTma5J2ijH8BnMtfK55dnjVp=dw@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	 <20180822154046.717610121@infradead.org>
	 <CA+55aFw6bBFnV__JZnzh0ZCSTma5J2ijH8BnMtfK55dnjVp=dw@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-hz++tz2+IaVsyr5y/rZl"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>


--=-hz++tz2+IaVsyr5y/rZl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2018-08-22 at 14:37 -0700, Linus Torvalds wrote:
> On Wed, Aug 22, 2018 at 8:46 AM Peter Zijlstra <peterz@infradead.org>
> wrote:
> >=20
> > Revert [..] in order to simplify the TLB invalidate fixes for x86.
> > We'll try again later.
>=20
> Rik, I assume I should take your earlier "yeah, I can try later" as
> an
> ack for this?

Yes, feel free to add my Acked-by: to all these
patches.

Patch 3/4 is not ideal, with the slow path in
tlb_remove_table sending two IPIs (one to every
CPU, one to the CPUs in the mm_cpumask), but
that is a slow path we should not be hitting
much anyway.

--=20
All Rights Reversed.

--=-hz++tz2+IaVsyr5y/rZl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlt933YACgkQznnekoTE
3oOMsAf/RJSe6V5kEnd6+uZ0fO6hjLhBKFelbSOom6tOoNv9xYtJb9aJY3dxw32J
5JBt5ihzQ2dGvSshTNYGY3okOXuq4gy46TrYGr7MS41yuHGEgBB/j8+48fWTGdAe
LzNXHGJ31Q+MACbk1MeHYAMvsWk32ri1u9sVelp3Cw3A/eACUsGaR8O0yC2zL/nJ
NZLofB9ceux/wnz+tg4wtubCE2AyirjJFmSTPjlbMhUeEEbkqp1B2UB7tBxwpKDl
buFJym74wL4KTMaxWH5dFEpVHolTSsFrdU+EdnDFSuP/LPMdJVo4CHxlGIWaUaEw
2l6Xqy7sF1U9kFT1azCKO2LzfHrdJQ==
=jSan
-----END PGP SIGNATURE-----

--=-hz++tz2+IaVsyr5y/rZl--
