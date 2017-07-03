Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCA096B0279
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 21:26:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l87so85274397qki.7
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 18:26:52 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id f88si13394002qtb.79.2017.07.02.18.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jul 2017 18:26:51 -0700 (PDT)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v8 05/10] mm: thp: enable thp migration in generic path
Date: Sun, 02 Jul 2017 21:26:48 -0400
Message-ID: <C4F49980-32D7-4888-A5BE-7B0B1977AACC@sent.com>
In-Reply-To: <20170702175732.okngzb6y6gwxrpdo@node.shutemov.name>
References: <20170701134008.110579-1-zi.yan@sent.com>
 <20170701134008.110579-6-zi.yan@sent.com>
 <20170702175732.okngzb6y6gwxrpdo@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_3481C5A9-04D1-4101-944E-1D9263AC69C9_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_3481C5A9-04D1-4101-944E-1D9263AC69C9_=
Content-Type: text/plain; markup=markdown
Content-Transfer-Encoding: quoted-printable

On 2 Jul 2017, at 13:57, Kirill A. Shutemov wrote:

> On Sat, Jul 01, 2017 at 09:40:03AM -0400, Zi Yan wrote:
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1302,6 +1302,7 @@ static bool try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
>>  	bool ret =3D true;
>>  	enum ttu_flags flags =3D (enum ttu_flags)arg;
>>
>> +
>>  	/* munlock has nothing to gain from examining un-locked vmas */
>>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>>  		return true;
>
> With exception of this useless hunk, looks good to me
>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>

Thanks.

BTW, is this Acked-by for Patch 5 or both Path 5 and 6?

--
Best Regards
Yan Zi

--=_MailMate_3481C5A9-04D1-4101-944E-1D9263AC69C9_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZWZ1YAAoJEEGLLxGcTqbMhjQIAIC0wohlGQG38vQ0b1rXCb7v
PI0dGeRswiiJKpWX12/aVQw+VyWNd47rMAK5p0cLUR42yTGpw0LPTsPvjogGnZa+
HSVx7VcFvpBsXHLkMaVjADCxXB7N4skcST3HIQ/h79R/DT5XHt5ylMSAVQiXQS8q
wUlwAKl5lyPhql3ISKY3pgMBdtRGQ0Z4vUbjx7C5QDKY4NKXPpM1rAur67c9alFm
StQoYpryNZmALutUGp0BrEyk53qNVJui+Br5pc6KfhgzU6Qx4beAQ/5p0aNobhnV
pJ9w6z/zDDmej4bYczFVKaMFq9/z1PMsw8eWnjyUYNwP86/Wq+CPDzdf+3jgd9w=
=lcWx
-----END PGP SIGNATURE-----

--=_MailMate_3481C5A9-04D1-4101-944E-1D9263AC69C9_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
