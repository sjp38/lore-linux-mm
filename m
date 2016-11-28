Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7237B6B0261
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:31:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so364387731pgd.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:31:31 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0118.outbound.protection.outlook.com. [104.47.41.118])
        by mx.google.com with ESMTPS id 3si26800225plz.158.2016.11.28.06.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 06:31:30 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 2/5] mm: migrate: Change migrate_mode to support
 combination migration modes.
Date: Mon, 28 Nov 2016 09:31:23 -0500
Message-ID: <A850A74A-3F72-4585-805C-25C72631C692@cs.rutgers.edu>
In-Reply-To: <5836A1A5.8050102@linux.vnet.ibm.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-3-zi.yan@sent.com> <5836A1A5.8050102@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_EE240745-9416-408A-9040-CE254C8CE96B_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <ziy@nvidia.com>

--=_MailMate_EE240745-9416-408A-9040-CE254C8CE96B_=
Content-Type: text/plain

On 24 Nov 2016, at 3:15, Anshuman Khandual wrote:

> On 11/22/2016 09:55 PM, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> From: Zi Yan <ziy@nvidia.com>
>>
>> No functionality is changed.
>
> The commit message need to contains more details like it changes
> the enum declaration from numbers to bit positions, where all it
> changes existing code like compaction and migration.
>

Sure. I will add more detail description in the next version.

>>
>> Signed-off-by: Zi Yan <ziy@nvidia.com>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>
> Like last patch please fix the author details and signed offs.
>

Got it.

--
Best Regards
Yan Zi

--=_MailMate_EE240745-9416-408A-9040-CE254C8CE96B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYPD+7AAoJEEGLLxGcTqbM8VoH/0gHTR8ziyioYeWK4hSMLuuV
W1rcui2s3iRc2YF/AH2GzBsxDKYUZSpTSj1nB9aZNj1k+O0BRyz5n/D50rCgc0nR
xosG0/6Ja20YPOM4Zn2d0hLBg1PLW8KpHHZfr5OzoP0bI2BnSiBlzicZFpG/P+P8
FV7MC+44U9uqBG1A6cepBqvL9aJNYjdX7ooDawTTZ2aX8UFGaltp4Z6SGDILlkqx
ozqW18+nnspPQ0K6Ckgar4pAhD84j8mRLJtKoQMued1LdKIdyp2d1TYlWYf5mFSV
zvUG+Gmou3t7/J2KgMYu1cgGdFeOVkv/uvesbNNBLYIiyGaKhXrzZwbN++63wS0=
=T/sO
-----END PGP SIGNATURE-----

--=_MailMate_EE240745-9416-408A-9040-CE254C8CE96B_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
