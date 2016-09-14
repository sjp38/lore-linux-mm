Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 146506B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:41:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 186so58668514itf.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:41:11 -0700 (PDT)
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com. [15.233.44.27])
        by mx.google.com with ESMTPS id d139si10266611oih.268.2016.09.14.07.40.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 07:40:53 -0700 (PDT)
Subject: Re: [kernel-hardening] [RFC PATCH v2 2/3] xpfo: Only put previous
 userspace pages into the hot cache
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-3-juerg.haefliger@hpe.com> <57D95FA3.3030103@intel.com>
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Message-ID: <7badeb6c-e343-4327-29ed-f9c9c0b6654b@hpe.com>
Date: Wed, 14 Sep 2016 16:40:49 +0200
MIME-Version: 1.0
In-Reply-To: <57D95FA3.3030103@intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="MvDRGgCgUqFIL4RSGlCO7Xs24fkENiwV2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MvDRGgCgUqFIL4RSGlCO7Xs24fkENiwV2
Content-Type: multipart/mixed; boundary="O1CtIAVv6aLLWs1NIc0rmG57UUaBW7E7P";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: Dave Hansen <dave.hansen@intel.com>, kernel-hardening@lists.openwall.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu
Message-ID: <7badeb6c-e343-4327-29ed-f9c9c0b6654b@hpe.com>
Subject: Re: [kernel-hardening] [RFC PATCH v2 2/3] xpfo: Only put previous
 userspace pages into the hot cache
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-3-juerg.haefliger@hpe.com> <57D95FA3.3030103@intel.com>
In-Reply-To: <57D95FA3.3030103@intel.com>

--O1CtIAVv6aLLWs1NIc0rmG57UUaBW7E7P
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On 09/14/2016 04:33 PM, Dave Hansen wrote:
> On 09/14/2016 12:19 AM, Juerg Haefliger wrote:
>> Allocating a page to userspace that was previously allocated to the
>> kernel requires an expensive TLB shootdown. To minimize this, we only
>> put non-kernel pages into the hot cache to favor their allocation.
>=20
> Hi, I had some questions about this the last time you posted it.  Maybe=

> you want to address them now.

I did reply: https://lkml.org/lkml/2016/9/5/249

=2E..Juerg


> --
>=20
> But kernel allocations do allocate from these pools, right?  Does this
> just mean that kernel allocations usually have to pay the penalty to
> convert a page?
>=20
> So, what's the logic here?  You're assuming that order-0 kernel
> allocations are more rare than allocations for userspace?
>=20



--O1CtIAVv6aLLWs1NIc0rmG57UUaBW7E7P--

--MvDRGgCgUqFIL4RSGlCO7Xs24fkENiwV2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJX2WFxAAoJEHVMOpb5+LSMrQoP/jtdf3Fbc1bSXJXL93ntuPf7
i3r1RKdrhfJgT8ScBPMs4PUahWaZMA/ktMfteu53+HXIIThGZNc5N5+T7VIrt7Xn
rj594vhVfeXftedOqjlRIO2r2LRubX6qD+7oRHf5yLHhdr7W1wgFv7cZModu6Nuj
h61J5RZoKGzogN0/Tn5hOoe6s6MS3qdcBaPNDFBTs0ZJz4s0X+i70pz9ysIH2jgS
kgxuQJ1bWnvZztlkzGJZLiK1CNBezHHy58zFyFx7HJTNR4G5FW+2nNyqVUUXIRvi
GddECUJaPPIIuIyNfeuiFqiJ5oYjuzhWKDbMfZXTaRfZr1mCtmUcwSjuiv/NlOJI
ynuq+A+GnTxSiXqQtenuARSzgz8QCkBi9ZuDzHU6wlSY3/GVO3XVf0yhqpYwEbQF
pHV3Rjrwkx+rOa35wTYkdR+JCEZZQoxQj9tXyGpctxrbZStc5eOuIRHzJu2mZo7P
eiGy4UsdNR+RtClauD+4QMLb4udStmFMG3RMwA78ioJYZE4j93QHGJN7+HBq/e7d
FuEkuWcAk/UsNVJdfuBjHyATNin+wjxrllEcPA4OPzHEbMevsXO4AE8ucmDSNGvD
hWa50Ahf8x/Zx/FvyBUSD7+g5c5CK9wNLdE70WwWUkphFGEhbJFhIm7wrTv0700g
KGlgI1DsXBwxzIzvnv/8
=T/wt
-----END PGP SIGNATURE-----

--MvDRGgCgUqFIL4RSGlCO7Xs24fkENiwV2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
