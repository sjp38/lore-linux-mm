Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id B1E5B6B0259
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 11:38:51 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id o11so58308136qge.2
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 08:38:51 -0800 (PST)
Received: from mail-qk0-x235.google.com (mail-qk0-x235.google.com. [2607:f8b0:400d:c09::235])
        by mx.google.com with ESMTPS id 68si15835976qge.98.2015.12.22.08.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 08:38:50 -0800 (PST)
Received: by mail-qk0-x235.google.com with SMTP id t125so150961063qkh.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 08:38:50 -0800 (PST)
Message-ID: <1450802317.15572.102.camel@gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC][PATCH 0/7] Sanitization of slabs
 based on grsecurity/PaX
From: Daniel Micay <danielmicay@gmail.com>
Date: Tue, 22 Dec 2015 11:38:37 -0500
In-Reply-To: <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
	 <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-R9P+6EvZ3pLH2YzinrHb"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Laura Abbott <laura@labbott.name>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>


--=-R9P+6EvZ3pLH2YzinrHb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> I am not sure what the point of this patchset is. We have a similar
> effect
> to sanitization already in the allocators through two mechanisms:

The rationale was covered earlier. Are you responding to that or did you
not see it?

> 1. Slab poisoning
> 2. Allocation with GFP_ZERO
>=20
> I do not think we need a third one. You could accomplish your goals
> much
> easier without this code churn by either
>=20
> 1. Improve the existing poisoning mechanism. Ensure that there are no
> =C2=A0=C2=A0=C2=A0gaps. Security sensitive kernel slab caches can then be=
 created
> with
> =C2=A0=C2=A0=C2=A0the=C2=A0=C2=A0POISONING flag set. Maybe add a Kconfig =
flag that enables
> =C2=A0=C2=A0=C2=A0POISONING for each cache? What was the issue when you t=
ried using
> =C2=A0=C2=A0=C2=A0posining for sanitization?
>=20
> 2. Add a mechanism that ensures that GFP_ZERO is set for each
> allocation.
> =C2=A0=C2=A0=C2=A0That way every object you retrieve is zeroed and thus y=
ou have
> implied
> =C2=A0=C2=A0=C2=A0sanitization. This also can be done in a rather simple =
way by
> changing
> =C2=A0=C2=A0=C2=A0the=C2=A0=C2=A0GFP_KERNEL etc constants to include __GF=
P_ZERO depending on a
> =C2=A0=C2=A0=C2=A0Kconfig option. Or add some runtime setting of the gfp =
flags
> somewhere.
>=20
> Generally I would favor option #2 if you must have sanitization
> because
> that is the only option to really give you a deterministic content of
> object on each allocation. Any half way measures would not work I
> think.
>=20
> Note also that most allocations are already either allocations that
> zero
> the content or they are immediately initializing the content of the
> allocated object. After all the object is not really usable if the
> content is random. You may be able to avoid this whole endeavor by
> auditing the kernel for locations where the object is not initialized
> after allocation.
>=20
> Once one recognizes the above it seems that sanitization is pretty
> useless. Its just another pass of writing zeroes before the allocator
> or
> uer of the allocated object sets up deterministic content of the
> object or
> -- in most cases -- zeroes it again.

Sanitization isn't just to prevent leaks from usage of uninitialized
data in later allocations. It's a mitigation for use-after-free (esp. if
it's combined with some form of delayed freeing) and it reduces the
lifetime of data.
--=-R9P+6EvZ3pLH2YzinrHb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJWeXyNAAoJEPnnEuWa9fIqjrYQAJaEzoGOlaw3y0rN4YRJU6+x
Ua7hjSxAY7iMM7zKYWqbz5XCjkqagdOCCcBgDhoo0q2NX6u9FPkfF2tBzggacLhk
GXrAXJf15dSv5zqfWlozyEmTGiuJSHDaYTibbGLrFoegXK5xSgSoCHiGpr1w2kXP
xA+Poc2F+S4+wkoF1gLb9I2w/4yRDDsWDtHIkVVBV1Tl85IYAA8cTSBJ3jO/VEe7
DoB1H7XzRvqqc/qeJnU/vMHleR4DcW4bp5oCYDL9UfzgGSvkf8c0NUViPSY9lAfZ
mYp6Y8tThRIoyONAHFPgUV9Rhe4ShBnRaoFCD1KO/LKRuFhOEfTGUQ6TRAYg7jgt
2dQJivBhBddKwKkGvw58IsOIDVkpAiqobWezrCbzIwvZCtyLi+MifBqmF6S75jCH
KYVjua1Ks7iWxNGqsCNUUbu7dMQ3z4xkB4j9O0GRJnWcIbTouGL1ReKyrXHIBJeS
zsTk+ElCaJntJGl2Gok0J8pgIvyXc13Kfblk+U5T3PcB11K6Gp/m1Sp4wWfz5mO6
+YP5WS1vZ/7g7FI5G/kUd8QPkcjkSDOlmRdV3QnYRSn7LYJThnF8P4buqi9iZ2e1
htC7VNwQIsAn6obkYgGQZ/XY6v6XHqJ96tmrGiiJNYsB7Y80HGkYXAt9QYZEpsWG
FNTuTLKN3YMErcOpwmsJ
=pRVv
-----END PGP SIGNATURE-----

--=-R9P+6EvZ3pLH2YzinrHb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
