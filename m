Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F07396B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 06:10:19 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d65so147499341ith.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 03:10:19 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id b185si3196491itb.24.2016.07.29.03.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 03:10:19 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id f6so6677804ith.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 03:10:19 -0700 (PDT)
Message-ID: <1469787002.10626.34.camel@gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH] [RFC] Introduce mmap
 randomization
From: Daniel Micay <danielmicay@gmail.com>
Date: Fri, 29 Jul 2016 06:10:02 -0400
In-Reply-To: <20160728210734.GU4541@io.lakedaemon.net>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
	 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
	 <20160726200309.GJ4541@io.lakedaemon.net>
	 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
	 <20160726205944.GM4541@io.lakedaemon.net>
	 <CAFJ0LnEZW7Y1zfN8v0_ckXQZn1n-UKEhf_tSmNOgHwrrnNnuMg@mail.gmail.com>
	 <20160728210734.GU4541@io.lakedaemon.net>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-7L3CSBziRWBjmI0R+yDs"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Nick Kralevich <nnk@google.com>
Cc: "Roberts, William C" <william.c.roberts@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>


--=-7L3CSBziRWBjmI0R+yDs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> > In the Project Zero Stagefright post
> > (http://googleprojectzero.blogspot.com/2015/09/stagefrightened.html)
> > ,
> > we see that the linear allocation of memory combined with the low
> > number of bits in the initial mmap offset resulted in a much more
> > predictable layout which aided the attacker. The initial random mmap
> > base range was increased by Daniel Cashman in
> > d07e22597d1d355829b7b18ac19afa912cf758d1, but we've done nothing to
> > address page relative attacks.
> >=20
> > Inter-mmap randomization will decrease the predictability of later
> > mmap() allocations, which should help make data structures harder to
> > find in memory. In addition, this patch will also introduce unmapped
> > gaps between pages, preventing linear overruns from one mapping to
> > another another mapping. I am unable to quantify how much this will
> > improve security, but it should be > 0.
>=20
> One person calls "unmapped gaps between pages" a feature, others call
> it
> a mess. ;-)

It's very hard to quantify the benefits of fine-grained randomization,
but there are other useful guarantees you could provide. It would be
quite helpful for the kernel to expose the option to force a PROT_NONE
mapping after every allocation. The gaps should actually be enforced.

So perhaps 3 things, simply exposed as off-by-default sysctl options (no
need for special treatment on 32-bit):

a) configurable minimum gap size in pages (for protection against linear
and small {under,over}flows)
b) configurable minimum gap size based on a ratio to allocation size
(for making the heap sparse to mitigate heap sprays, especially when
mixed with fine-grained randomization - for example 2x would add a 2M
gap after a 1M mapping)
c) configurable maximum random gap size (the random gap would be in
addition to the enforced minimums)

The randomization could just be considered an extra with minor benefits
rather than the whole feature. A full fine-grained randomization
implementation would need a higher-level form of randomization than gaps
in the kernel along with cooperation from userspace allocators. This
would make sense as one part of it though.
--=-7L3CSBziRWBjmI0R+yDs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIzBAABCAAdBQJXmyt6FhxkYW5pZWxtaWNheUBnbWFpbC5jb20ACgkQ+ecS5Zr1
8ipPGxAAgXNziBxf6snaEWRnS0vJfBg3zJkzfs9AxgM/j3Nf5efTCN0VaNKctqbc
A6gL83PtFqT681ZEb/ILALkBCk892o6b1yU+uibXLPJTDGJkVmzgrVMNdZ0lUKdH
mVbupdcnBqrZ1RsThShnOC9F1OfCtkAq8y+G5amKaN6pubu83ohdGFa4JtWsq1Hp
E1BuYThA9SNV4fG5AmwLMAy7TOg98zG5fQ4AxORAKUTIIbypw1FoXfCuhhzLToRF
scLwMg2ElhlwXk9zgW05LfOUisDNqYj2kAoJQekYCvXhB4p2iAXe7KYrID2e0V/P
zlVyEU2QrNFikFuWzktWW7o8NK0wKGEVgoF11QOsGEx1suj5XeebJfgy49IpwIo8
+TSXLr2vYMSIhFdx/QWQJxIFQEGTJuZu8/fl1BE01rCl93zcQiuZHepwCe9I6Wlp
z73izV2xMrTSjPNfZjuqGhdcjTSBGCW9XqB1NybKqAAczVizvWjclTWtYWzmqGax
VqUqiEgx2rOQ/56RuAJn44o+geeYmtoH8gppSMiJcXiCdX1pYpJZYAYVYFDlO/bB
XOVLwjEMwGL8LAGXZYQH6bW3f73UdyDFXQrShnyHnYk8REebbQIUetWvU9Lmbzyc
fCDRufi6ebQjn40ne/nhlVmpZlTGl3We3fIIhAX8/AfWHvXU2i8=
=tPV0
-----END PGP SIGNATURE-----

--=-7L3CSBziRWBjmI0R+yDs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
