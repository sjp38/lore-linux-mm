Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFFFD6B0038
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 07:54:51 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g185so49983704ith.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 04:54:51 -0700 (PDT)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id q17si1125788oic.133.2016.09.05.04.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 04:54:50 -0700 (PDT)
Subject: Re: [RFC PATCH v2 2/3] xpfo: Only put previous userspace pages into
 the hot cache
References: <1456496467-14247-1-git-send-email-juerg.haefliger@hpe.com>
 <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160902113909.32631-3-juerg.haefliger@hpe.com> <57C9E37A.9070805@intel.com>
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Message-ID: <e7a0789e-585c-839d-d8ea-95b1c9aef38a@hpe.com>
Date: Mon, 5 Sep 2016 13:54:47 +0200
MIME-Version: 1.0
In-Reply-To: <57C9E37A.9070805@intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="feNkja7ck77XjJ8qB7LALqg0b3p8XSw7t"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--feNkja7ck77XjJ8qB7LALqg0b3p8XSw7t
Content-Type: multipart/mixed; boundary="HHOVQnPV2XNCXH9POK17P2Fj5EiJGnEta";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, kernel-hardening@lists.openwall.com,
 linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu
Message-ID: <e7a0789e-585c-839d-d8ea-95b1c9aef38a@hpe.com>
Subject: Re: [RFC PATCH v2 2/3] xpfo: Only put previous userspace pages into
 the hot cache
References: <1456496467-14247-1-git-send-email-juerg.haefliger@hpe.com>
 <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160902113909.32631-3-juerg.haefliger@hpe.com> <57C9E37A.9070805@intel.com>
In-Reply-To: <57C9E37A.9070805@intel.com>

--HHOVQnPV2XNCXH9POK17P2Fj5EiJGnEta
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 09/02/2016 10:39 PM, Dave Hansen wrote:
> On 09/02/2016 04:39 AM, Juerg Haefliger wrote:
>> Allocating a page to userspace that was previously allocated to the
>> kernel requires an expensive TLB shootdown. To minimize this, we only
>> put non-kernel pages into the hot cache to favor their allocation.
>=20
> But kernel allocations do allocate from these pools, right?

Yes.


> Does this
> just mean that kernel allocations usually have to pay the penalty to
> convert a page?

Only pages that are allocated for userspace (gfp & GFP_HIGHUSER =3D=3D GF=
P_HIGHUSER) which were
previously allocated for the kernel (gfp & GFP_HIGHUSER !=3D GFP_HIGHUSER=
) have to pay the penalty.


> So, what's the logic here?  You're assuming that order-0 kernel
> allocations are more rare than allocations for userspace?

The logic is to put reclaimed kernel pages into the cold cache to postpon=
e their allocation as long
as possible to minimize (potential) TLB flushes.

=2E..Juerg



--HHOVQnPV2XNCXH9POK17P2Fj5EiJGnEta--

--feNkja7ck77XjJ8qB7LALqg0b3p8XSw7t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXzV0HAAoJEHVMOpb5+LSM304QAINSMlOQKNAIRon29Uy318Sf
J9Vfv3p2L/WIxrL6kKaHYkDqj+b0XnSVlWvnxNp1MX1qAOqeUSipfymvwNaYGuIV
IJQeahOcJccupJMw1ILF+H1Rhxn+gBOc9I745omwO/CtlqYaYaXfCeIxI/R1Q9LQ
yCtBPnbL4v1St7FnjDhZd3FdgiP+F98MAz8040FYq1cO+qWVDTyIRcpq4rPaAJNi
8zcpLB+A34qjA2i3ZFV/ZNls2L4Buw4pYW1ZGnHxNTKKmbrYkZhBuxYuCNpfnyhB
M00AnBKJQ7fqHKxCa64eo59rRTpYQ0Zd8KaKvVaZfZfbBaAg8Ir2UWNoBcPvE8ox
D8TMhKlORMhHfnAE73DIlkENt1wYt2gGGScIJ+bL8nulJpqvNo5lPyTT3NHhrNZa
prre5DzDQFvyv2SLx2P3MDqtyJ658hKx5own+82N99K5GuhC2++Xaq3/BpOC4rQI
rEONoXhm0j63g2udCmkc1BIRSb+ZTaqzC1fxWoYH75nYEiIhGcgTQVJWXMx5DB/Y
gvJJn/okC97zSXGk8zQtYIO2aDhUzRowYoy5bslzlR20hoNTWL9ctySE2OobqIdM
WmWm/Hyq59cAMneimMv68+/RiWtxL2s5Q+8lci8uf18ollN1g/zp6H/1qOOMWvAr
vqBZxyugEM72PbSEFv8Y
=Jva/
-----END PGP SIGNATURE-----

--feNkja7ck77XjJ8qB7LALqg0b3p8XSw7t--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
