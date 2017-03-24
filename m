Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7E566B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 10:22:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k11so1386445pfk.11
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:22:43 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0125.outbound.protection.outlook.com. [104.47.40.125])
        by mx.google.com with ESMTPS id s1si3081520plk.31.2017.03.24.07.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 07:22:37 -0700 (PDT)
Message-ID: <58D52B78.9040303@cs.rutgers.edu>
Date: Fri, 24 Mar 2017 09:21:44 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v4 04/11] mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
References: <20170313154507.3647-1-zi.yan@sent.com> <20170313154507.3647-5-zi.yan@sent.com> <20170324141037.2eyovzq2bmcdmwzu@node.shutemov.name>
In-Reply-To: <20170324141037.2eyovzq2bmcdmwzu@node.shutemov.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enig5D705F49D9F339D812D23E26"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

--------------enig5D705F49D9F339D812D23E26
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Kirill A. Shutemov wrote:
> On Mon, Mar 13, 2017 at 11:45:00AM -0400, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
>> functionality to x86_64, which should be safer at the first step.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> ---
>> v1 -> v2:
>> - fixed config name in subject and patch description
>> ---
>>  arch/x86/Kconfig        |  4 ++++
>>  include/linux/huge_mm.h | 10 ++++++++++
>>  mm/Kconfig              |  3 +++
>>  3 files changed, 17 insertions(+)
>>
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 69188841717a..a24bc11c7aed 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -2276,6 +2276,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
>>  	def_bool y
>>  	depends on X86_64 && HUGETLB_PAGE && MIGRATION
>> =20
>> +config ARCH_ENABLE_THP_MIGRATION
>> +	def_bool y
>> +	depends on X86_64 && TRANSPARENT_HUGEPAGE && MIGRATION
>> +
>=20
> TRANSPARENT_HUGEPAGE implies MIGRATION due to COMPACTION.
>=20

Sure. I will change it to:

+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on X86_64 && TRANSPARENT_HUGEPAGE
+


Thanks.

--=20
Best Regards,
Yan Zi


--------------enig5D705F49D9F339D812D23E26
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJY1SuhAAoJEEGLLxGcTqbM0BUH/iMBTNr7Nrc154brgXZ6qd1t
sbS9UaaYsC3OwKMr34x5aW2pbSIsN4m3+fVX2y3BjbuNeUsE0V7ZgHzF7jrYj4Ve
9iEye/HtJYdzSwG460h/YrMyqmdYZ8qhUc5so6s0AwC9SByssNxob7PZkosZQOMj
1INE77dg+4mdHnrziSbhCdvHjAOvtf4AuedGPqcVQURU3NGVNo0R8EbfRNfAaR+L
0sf6yjmbACBSeDSkTFSZ6ZjEtuR5tvacVlQ28kaDs9dd3M49SQ56h0Sj2jO/gRDP
mZsOhZUzUIwR9eYJsB5yKnyc76Yp+iNXzz+PfMu5AMMXgXeUQIshJQcHzMyIzZA=
=BHEx
-----END PGP SIGNATURE-----

--------------enig5D705F49D9F339D812D23E26--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
