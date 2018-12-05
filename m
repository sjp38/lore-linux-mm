Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 242306B717A
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:18:32 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id d23so13660722plj.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:18:32 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id a11si16090026pga.198.2018.12.04.16.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 16:18:30 -0800 (PST)
Date: Wed, 5 Dec 2018 11:18:21 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2018-12-04-16-00 uploaded
Message-ID: <20181205111821.76f2b1dd@canb.auug.org.au>
In-Reply-To: <20181205000059.PQ0hs%akpm@linux-foundation.org>
References: <20181205000059.PQ0hs%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/UaHe6/stNTjgMwUpk/mEyTN"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: broonie@kernel.org, mhocko@suse.cz, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

--Sig_/UaHe6/stNTjgMwUpk/mEyTN
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Tue, 04 Dec 2018 16:00:59 -0800 akpm@linux-foundation.org wrote:
>
> * async-remove-some-duplicated-includes.patch

This patch has the wrong subject line (mentions kernel/signal.c).

--=20
Cheers,
Stephen Rothwell

--Sig_/UaHe6/stNTjgMwUpk/mEyTN
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlwHGU0ACgkQAVBC80lX
0GwVBgf/cNsclajJcaBCcidSR1LIRfzy7FplBOh7SEYt+DRwlmJl2JXjsxrWxW7i
G66BHyDr/P0c2qbu1Ulm3qhIq2kRUGrFVUiDZrbtc5K9G4qaF/DImCgnV/lY8JWz
LX/xioqWthcoGcDnnCTlgfX00QYdfvTLXJ1rX6GLZ6uNsYkh0q1y+KMyFyQkxowR
vOMf/ZFWsHsmJ/NQAj/v4WFCWGfLPh9m5rg2T5srVuTUdH7NtSso3HSdTo+HNOIq
x9Cm9SdjhLHWulyd3gIwBqXcCrRrscMPURAA67Zv8eNekOxuvwHGfGte6M4E+YDV
wGTTnastlHEFt7AskGh8pH89VzirFA==
=HBMt
-----END PGP SIGNATURE-----

--Sig_/UaHe6/stNTjgMwUpk/mEyTN--
