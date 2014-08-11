Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A09EB6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 07:54:50 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so10700245pdi.34
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 04:54:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ev6si13281426pac.56.2014.08.11.04.54.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Aug 2014 04:54:49 -0700 (PDT)
Date: Mon, 11 Aug 2014 13:54:31 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH]  export the function kmap_flush_unused.
Message-ID: <20140811115431.GW9918@twins.programming.kicks-ass.net>
References: <3C85A229999D6B4A89FA64D4680BA6142C7DFA@SHSMSX101.ccr.corp.intel.com>
 <53E4D312.5000601@codeaurora.org>
 <3C85A229999D6B4A89FA64D4680BA6142CAFF3@SHSMSX101.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PPU/y5W3JEc6wR1b"
Content-Disposition: inline
In-Reply-To: <3C85A229999D6B4A89FA64D4680BA6142CAFF3@SHSMSX101.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sha, Ruibin" <ruibin.sha@intel.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "mgorman@suse.de" <mgorman@suse.de>, "mingo@redhat.com" <mingo@redhat.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "He, Bo" <bo.he@intel.com>


--PPU/y5W3JEc6wR1b
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 11, 2014 at 01:26:45AM +0000, Sha, Ruibin wrote:
> Hi Chintan,
> Thank you very much for your timely and kindly response and comments.
>=20
> Here is more detail about our Scenario:
>=20
>     We have a big driver on Android product. The driver allocates lots of
>     DDR pages. When applications mmap a file exported from the driver,
>     driver would mmap the pages to the application space, usually with
>     uncachable prot.
>     On ia32/x86_64 arch, we have to avoid page cache alias issue. When
>     driver allocates the pages, it would change page original mapping in
>     page table with uncachable prot. Sometimes, the allocated page was
>     used by kmap/kunmap. After kunmap, the page is still mapped in KMAP
>     space. The entries in KMAP page table are not cleaned up until a
>     kernel thread flushes the freed KMAP pages(usually it is woken up by =
kunmap).
>     It means the driver need  force to flush the KMAP page table entries =
before mapping pages to
>     application space to be used. Otherwise, there is a race to create
>     cache alias.
>=20
>     To resolve this issue, we need export function kmap_flush_unused as
>     the driver is compiled as module. Then, the driver calls
>     kmap_flush_unused if the allocated pages are in HIGHMEM and being
>     used by kmap.

A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
A: Top-posting.
Q: What is the most annoying thing in e-mail?

That said, it sounds like you want set_memory_() to call
kmap_flush_unused(). Because this race it not at all specific to your
usage, it could happen to any set_memory_() site, right?

--PPU/y5W3JEc6wR1b
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT6K7yAAoJEHZH4aRLwOS684sQAK4J9mCnVRUMUPR7DHtyfh0m
jv8U6nSsXIQ5pY454Z/zxXMnhWTKqFJ5e+QzRdgTZC24pg4dj1qzQImXcdjwuPTN
3gUlDoajSU2IXT3JODFtSfKm/weylsWaObzn6ou7t3FboPLhfymrAdR0nkbO+bxh
Vpz9SPnAMQqPXeTbLzbPUfB0udtUzudFkk85tP+okGpj13uqvfTpEqX0EnaIk9hS
Zb9t+W49z3e4T9B6NWuA2PBhVWMRKrpGAdKq9/OqkFierwLKkt1UFLuP84VUedwZ
haEKlLlp6mT/DfP8v62cGXOSZrDTDxm9fSeZVhPUlNzwpSXcJg+BNWrpW58wLs1g
mNHIBe/a+tRwqZ2WwSkDD5kJWHAhqkbeOfzt6+lmRh/bZinwm7urpW/KDMZcnvGV
S8qKXNhY2I0mzKzkxok1vB7GRP/OLjjauRfNk7WxVJNV++gq7AcyQYzNhzWPhKw7
hpx+Y7NEqnHPHbBirq0jqrv8GeNuZCfwWZfi60M3d3K62Zx14rpDkySiCdMNpJq5
ebPGpa49VAaxhzpR7Tr2aIltDet5C3rJOioQp4qrUjvpkbdCYvoxzxgD1AIDZNvX
7cp+dbYsT3f242Nl0uGgxznsrcr6e6lhzEFkmLm9mVSI6NjClJs/OA8EJ3VELKSo
TwQfCfSE2FOWWezBk0jR
=vCVR
-----END PGP SIGNATURE-----

--PPU/y5W3JEc6wR1b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
