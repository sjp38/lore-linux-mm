Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2E636B2DFE
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 01:25:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q21-v6so5241997pff.21
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 22:25:46 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id b9-v6si6624605pfi.99.2018.08.23.22.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 Aug 2018 22:25:45 -0700 (PDT)
Date: Fri, 24 Aug 2018 15:25:41 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT PULL] XArray for 4.19
Message-ID: <20180824152541.3553a8cc@canb.auug.org.au>
In-Reply-To: <CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
References: <20180813161357.GB1199@bombadil.infradead.org>
	<CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/eTQPGCSlA1hGnl5O.I6Lyi0"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--Sig_/eTQPGCSlA1hGnl5O.I6Lyi0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Linus,

On Tue, 21 Aug 2018 19:09:31 -0700 Linus Torvalds <torvalds@linux-foundatio=
n.org> wrote:
>
> For some unfathomable reason, you have based it on the libnvdimm tree.
> I don't understand at all wjhy you did that.

That was partly my fault for giving not very good advice when the
(quite complex) merge conflict turned up in the linux-next tree.  I
will try to give better advice in the future.

--=20
Cheers,
Stephen Rothwell

--Sig_/eTQPGCSlA1hGnl5O.I6Lyi0
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlt/ltUACgkQAVBC80lX
0Gy/tgf/XrHWEdPxK3PFOvQTMG8aUVpqmkA+ggelCwrXVXK3QoAWV1fSUc70RzRd
GDFbkjdI31YaJij+BuTJkOQt3p/aQ/kr0QCBJTh4ZHS3qEfkHQXbJTUH1Q3jnxuH
8ze7k4z3wfcTMMZCNRwdxVht0/dRxUO1roJBqcwnxS2Hjnu+kuqXTOYG/BI9EZii
cmyK9JM9Cl1a8rK9yQ7y7xWGrh6+tWrjwX9ED/0cFPioDpDxplrx21pN7wdA2OvY
FTALotroiMCfJyNF4claRsxAH8FxW1jz9Dy+zOapuFfOQGJUVh6Btlnr9/MyL32c
DO9ImcA8kAXIq5kflYhjAt+gEchmPg==
=oNGr
-----END PGP SIGNATURE-----

--Sig_/eTQPGCSlA1hGnl5O.I6Lyi0--
