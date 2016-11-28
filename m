Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 090756B0260
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:13:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so217972865pfx.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:13:57 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0090.outbound.protection.outlook.com. [104.47.37.90])
        by mx.google.com with ESMTPS id g17si55498361pgh.51.2016.11.28.07.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 07:13:56 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 1/5] mm: migrate: Add mode parameter to support additional
 page copy routines.
Date: Mon, 28 Nov 2016 10:13:48 -0500
Message-ID: <B5823455-07C1-46A8-8F05-A109E9935A20@cs.rutgers.edu>
In-Reply-To: <dbb93172-4dd1-e88e-f65d-321ac7882999@gmail.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-2-zi.yan@sent.com>
 <dbb93172-4dd1-e88e-f65d-321ac7882999@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_6BEE98CB-C8FE-460C-9B23-62E71A4F8271_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com

--=_MailMate_6BEE98CB-C8FE-460C-9B23-62E71A4F8271_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 24 Nov 2016, at 18:56, Balbir Singh wrote:

> On 23/11/16 03:25, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> From: Zi Yan <ziy@nvidia.com>
>>
>> migrate_page_copy() and copy_huge_page() are affected.
>>
>> Signed-off-by: Zi Yan <ziy@nvidia.com>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  fs/aio.c                |  2 +-
>>  fs/hugetlbfs/inode.c    |  2 +-
>>  fs/ubifs/file.c         |  2 +-
>>  include/linux/migrate.h |  6 ++++--
>>  mm/migrate.c            | 14 ++++++++------
>>  5 files changed, 15 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/aio.c b/fs/aio.c
>> index 428484f..a67c764 100644
>> --- a/fs/aio.c
>> +++ b/fs/aio.c
>> @@ -418,7 +418,7 @@ static int aio_migratepage(struct address_space *m=
apping, struct page *new,
>>  	 * events from being lost.
>>  	 */
>>  	spin_lock_irqsave(&ctx->completion_lock, flags);
>> -	migrate_page_copy(new, old);
>> +	migrate_page_copy(new, old, 0);
>
> Can we have a useful enum instead of 0, its harder to read and understa=
nd
> 0

How about MIGRATE_SINGLETHREAD =3D 0 ?


>>  	BUG_ON(ctx->ring_pages[idx] !=3D old);
>>  	ctx->ring_pages[idx] =3D new;
>>  	spin_unlock_irqrestore(&ctx->completion_lock, flags);
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 4fb7b10..a17bfef 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -850,7 +850,7 @@ static int hugetlbfs_migrate_page(struct address_s=
pace *mapping,
>>  	rc =3D migrate_huge_page_move_mapping(mapping, newpage, page);
>>  	if (rc !=3D MIGRATEPAGE_SUCCESS)
>>  		return rc;
>> -	migrate_page_copy(newpage, page);
>> +	migrate_page_copy(newpage, page, 0);
>
> Ditto
>
>>
>>  	return MIGRATEPAGE_SUCCESS;
>>  }
>> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
>> index b4fbeef..bf54e32 100644
>> --- a/fs/ubifs/file.c
>> +++ b/fs/ubifs/file.c
>> @@ -1468,7 +1468,7 @@ static int ubifs_migrate_page(struct address_spa=
ce *mapping,
>>  		SetPagePrivate(newpage);
>>  	}
>>
>> -	migrate_page_copy(newpage, page);
>> +	migrate_page_copy(newpage, page, 0);
>
> Here as well
>
>
> Balbir Singh.


--
Best Regards
Yan Zi

--=_MailMate_6BEE98CB-C8FE-460C-9B23-62E71A4F8271_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYPEmsAAoJEEGLLxGcTqbMEfQH/iGys3IHsRuqE8ka0/SAL9ya
DkyF+t98fB5luJpzVrrOUh/7Sj3tejY+1CAYmCoHx408dm9MhfS95JULCxMxR5Ny
MQ3gz1sV6R4PG/BYt74w7w1tN5Q6iD0ha2SOl8KnGp11iNV1H+fvEBQ8Yp09GZIs
4EiX4yr5AcII6gfsZJJl5+3oZN+C4bscAI2ES6cRN9ZaRO0asb9cYbRPxoCQ1ZC/
19a1z2lSCxeWOkQgrrJqrfewDG0O75ZXF8j/kwismYWz9PjowDrXifYHey1l2l2I
NpVMPOjobgdLbvQT3ibKhlZHPZY9+U0u7s8N7ncRHiC1tZ84DbIBg69g7BrbtDI=
=0I96
-----END PGP SIGNATURE-----

--=_MailMate_6BEE98CB-C8FE-460C-9B23-62E71A4F8271_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
