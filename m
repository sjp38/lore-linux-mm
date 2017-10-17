Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 711226B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:33:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 76so1237334pfr.3
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:33:50 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0103.outbound.protection.outlook.com. [104.47.41.103])
        by mx.google.com with ESMTPS id k9si5452794pgn.175.2017.10.17.05.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 05:33:49 -0700 (PDT)
Message-ID: <59E5F881.20105@cs.rutgers.edu>
Date: Tue, 17 Oct 2017 08:33:05 -0400
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm, pagemap: Fix soft dirty marking for PMD migration
 entry
References: <20171017081818.31795-1-ying.huang@intel.com> <20171017112100.pciya6pmo62owpht@node.shutemov.name> <874lqy7yks.fsf@yhuang-dev.intel.com>
In-Reply-To: <874lqy7yks.fsf@yhuang-dev.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enigF497273E0D159290A3F1632C"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?Su+/vXLvv71tZSBHbGlzc2U=?= <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF497273E0D159290A3F1632C
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Huang, Ying wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
>=20
>> On Tue, Oct 17, 2017 at 04:18:18PM +0800, Huang, Ying wrote:
>>> From: Huang Ying <ying.huang@intel.com>
>>>
>>> Now, when the page table is walked in the implementation of
>>> /proc/<pid>/pagemap, pmd_soft_dirty() is used for both the PMD huge
>>> page map and the PMD migration entries.  That is wrong,
>>> pmd_swp_soft_dirty() should be used for the PMD migration entries
>>> instead because the different page table entry flag is used.
>>>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>> Cc: David Rientjes <rientjes@google.com>
>>> Cc: Arnd Bergmann <arnd@arndb.de>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: "J.r.me Glisse" <jglisse@redhat.com>
>>> Cc: Daniel Colascione <dancol@google.com>
>>> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> What is effect of the misbehaviour? pagemap reports garbage?
>=20
> Yes.  pagemap may report incorrect soft dirty information for PMD
> migration entries.

Thanks for fixing it.

>=20
>> Shoudn't it be in stable@? And maybe add Fixes: <sha1>.
>=20
> Yes.  Will do that in the next version.

PMD migration is merged in 4.14, which is not final yet. Do we need to
split the patch, so that first hunk(for present PMD entries) goes into
stable and second hunk(for PMD migration entries) goes into 4.14?

--=20
Best Regards,
Yan Zi


--------------enigF497273E0D159290A3F1632C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJZ5fikAAoJEEGLLxGcTqbM2TcH/2CesC87hAUtSTJsDHG4m7bh
d1HKfIZR500c9cSz0xiDxsGIgzGSg3nxpkxwjohkTmnNZVLIlRgdJXhXyW3dXLdq
gGstfVIxM7eyFdBU91t8Sc/RCxHqUyqQoeK+OTLaB6Mg2F1iGba2FJzd9ft2ggNx
G6RovCEX8Ya4iq9sjKu0Uv7+uKJdxnENbHxbi4MEclOlcoXTXmRKpps2DezyPY4Q
+4OnPz0fJW7jKEko9aZb3/MSXqJyQL1SGwJGmHDroutLoDH/2OJOtcrZtvkctwZ0
pYP4OhjSixnvZ/1uoih4fJHgtwYz/FlvmipazKn83+omSIk4jDVlbxwBeYtn8yM=
=YB8W
-----END PGP SIGNATURE-----

--------------enigF497273E0D159290A3F1632C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
