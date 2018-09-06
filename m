Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A139B6B7A91
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 16:30:14 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id u22-v6so8819709qkk.10
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 13:30:14 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id j9-v6si1046419qtb.398.2018.09.06.13.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 13:30:11 -0700 (PDT)
Message-ID: <fa7c625dfbbe103b37bc3ab5ea4b7283fd13b998.camel@surriel.com>
Subject: Re: [RFC PATCH 1/2] mm: move tlb_table_flush to tlb_flush_mmu_free
From: Rik van Riel <riel@surriel.com>
Date: Thu, 06 Sep 2018 16:29:59 -0400
In-Reply-To: <20180823084709.19717-2-npiggin@gmail.com>
References: <20180823084709.19717-1-npiggin@gmail.com>
	 <20180823084709.19717-2-npiggin@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-QttmgVvdlWOXMEILqZsq"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org


--=-QttmgVvdlWOXMEILqZsq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2018-08-23 at 18:47 +1000, Nicholas Piggin wrote:
> There is no need to call this from tlb_flush_mmu_tlbonly, it
> logically belongs with tlb_flush_mmu_free. This allows some
> code consolidation with a subsequent fix.
>=20
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>

Reviewed-by: Rik van Riel <riel@surriel.com>

This patch also fixes an infinite recursion bug
with CONFIG_HAVE_RCU_TABLE_FREE enabled, which
has this call trace:

tlb_table_flush
  -> tlb_table_invalidate
     -> tlb_flush_mmu_tlbonly
        -> tlb_table_flush
           -> ... (infinite recursion)

This should probably be applied sooner rather than
later.

--=20
All Rights Reversed.

--=-QttmgVvdlWOXMEILqZsq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAluRjkcACgkQznnekoTE
3oOfdAgAgn63e88Lj0I9lDDOx5WKhEfgPfWM7o5JhGZg8FxNA8lfLlgA3tFPYd4+
mYWwbBpKSf+yLLRvy4V7V4pv7b0gk7jYTvxir3iOfFcFZ0OQVKYrbr2+txZJb6Xj
tosM9v5SsYMwJHGw+1cD0DQsvR/6uio0TthxchcpV4bNVvW1X8HlzFarPY32kpf8
HRU7NF/7gS2sxPQLPC/i+m4YgnuIq5xfseMOVVFp7H+uNI5BLCyrDm74zbFbtj1A
HtFG9Yp4pj0KX/Bq7oiLOQ9suEtcJUI46sERyergDvFFRhTwoBGRxJ/wbKRQkxIF
elqWT6jifgV0u6aRFHPPkEIuIUdTbg==
=/CHW
-----END PGP SIGNATURE-----

--=-QttmgVvdlWOXMEILqZsq--
