Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 27DBE6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:41:48 -0400 (EDT)
Received: by oifl3 with SMTP id l3so36764506oif.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:41:47 -0700 (PDT)
Received: from mezzanine.sirena.org.uk (mezzanine.sirena.org.uk. [2400:8900::f03c:91ff:fedb:4f4])
        by mx.google.com with ESMTPS id fp4si4365001pac.23.2015.03.25.09.20.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 09:20:46 -0700 (PDT)
Date: Wed, 25 Mar 2015 09:20:56 -0700
From: Mark Brown <broonie@kernel.org>
Message-ID: <20150325162056.GG3572@sirena.org.uk>
References: <201503250933.dBZIxVT3%fengguang.wu@intel.com>
 <1427282984-29296-1-git-send-email-javi.merino@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ulDeV4rPMk/y39in"
Content-Disposition: inline
In-Reply-To: <1427282984-29296-1-git-send-email-javi.merino@arm.com>
Subject: Re: [PATCH] ASoC: pcm512x: use DIV_ROUND_CLOSEST_ULL() from kernel.h
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Javi Merino <javi.merino@arm.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Rosin <peda@axentia.se>, Liam Girdwood <lgirdwood@gmail.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>


--ulDeV4rPMk/y39in
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 25, 2015 at 11:29:44AM +0000, Javi Merino wrote:
> Now that the kernel provides DIV_ROUND_CLOSEST_ULL(), drop the internal
> implementation and use the kernel one.

Acked-by: Mark Brown <broonie@kernel.org>

--ulDeV4rPMk/y39in
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVEuBnAAoJECTWi3JdVIfQIKgH/Ai3PZAB5dNdAI83kLJIP1Fy
fWCr+8g6EP/hTFpKGJOa+u1C2klN4rIqrEBESrDAF3zLLsKDHUTKxnfyJiMUibTh
Z0luTmblQ4EoiNl3cn0QpBfJXzi0f8Q302VXgT5t8zRlennjLcH1Nujw8Wn0UXVN
UcIRRhBNA3+KKq4O4x1A29eCKyQMa2TWtgCxESV7s7SONImMXIP6h4+QBQdZJQtt
L4Tv2ueKwwef91pgdYafh+BuS7ksxZ509oq5UpG2vCS01GmcawQEJhVj7DMauk0j
pQUXI8o369qYFD4cZCOUGJnu1gkFRhVi8bizXzmYqiSRAvGSozMy8JDF5dFaOcE=
=NCvM
-----END PGP SIGNATURE-----

--ulDeV4rPMk/y39in--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
