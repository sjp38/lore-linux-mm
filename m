Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A36386B7EC3
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 10:28:22 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w126-v6so10582624qka.11
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 07:28:22 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id w136-v6si4198181qkb.110.2018.09.07.07.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 07:28:20 -0700 (PDT)
Message-ID: <b686a7e397b992cf7a32b2e5e7c3503919a8c717.camel@surriel.com>
Subject: Re: [RFC PATCH 1/2] mm: move tlb_table_flush to tlb_flush_mmu_free
From: Rik van Riel <riel@surriel.com>
Date: Fri, 07 Sep 2018 10:28:05 -0400
In-Reply-To: <20180907134359.GA12187@arm.com>
References: <20180823084709.19717-1-npiggin@gmail.com>
	 <20180823084709.19717-2-npiggin@gmail.com>
	 <fa7c625dfbbe103b37bc3ab5ea4b7283fd13b998.camel@surriel.com>
	 <20180907134359.GA12187@arm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-IFHu9I6W7+At+9sCwKHu"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org


--=-IFHu9I6W7+At+9sCwKHu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2018-09-07 at 14:44 +0100, Will Deacon wrote:
> On Thu, Sep 06, 2018 at 04:29:59PM -0400, Rik van Riel wrote:
> > On Thu, 2018-08-23 at 18:47 +1000, Nicholas Piggin wrote:
> > > There is no need to call this from tlb_flush_mmu_tlbonly, it
> > > logically belongs with tlb_flush_mmu_free. This allows some
> > > code consolidation with a subsequent fix.
> > >=20
> > > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> >=20
> > Reviewed-by: Rik van Riel <riel@surriel.com>
> >=20
> > This patch also fixes an infinite recursion bug
> > with CONFIG_HAVE_RCU_TABLE_FREE enabled, which
> > has this call trace:
> >=20
> > tlb_table_flush
> >   -> tlb_table_invalidate
> >      -> tlb_flush_mmu_tlbonly
> >         -> tlb_table_flush
> >            -> ... (infinite recursion)
> >=20
> > This should probably be applied sooner rather than
> > later.
>=20
> It's already in mainline with a cc stable afaict.

Sure enough, it is.

I guess I have too many kernel trees on this
system, and was looking at the wrong one somehow.

--=20
All Rights Reversed.

--=-IFHu9I6W7+At+9sCwKHu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAluSivUACgkQznnekoTE
3oPhFwf/Qd/rrFLYEKAcJENv34o7Gk0YNVmPKKhyg9sj8nteRac1mnyeVpqmXfWW
4yDdUx6glji8FWttmnTcpbb/frJlwsKFYBsoYDxBc/D73sTf+3Q8aAbhYAYGzcDq
GNANhQ1BQXNHL5YfEZtpCFha66ZpAAPEMr+1PI6/k4oMWIOW+EqXko92WP+Vwr9I
jfYaqKq9UfwFmy/ftaynlXP8yQjlSc2mYTA1SOEuAyiquvBH3TZo2f7bALCA1wP/
i0lLnEPvFwlgxXDg5l2d/aQxbW4j2KnFLZ3AJMZpPhTfcWanSVSpkxOfZlmXQnPp
DgV4H7ZrKkvWgRg8+/l1CpXX4ulpRA==
=4rvN
-----END PGP SIGNATURE-----

--=-IFHu9I6W7+At+9sCwKHu--
