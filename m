Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D44A76B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 10:03:42 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id c25so88014753qtg.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 07:03:42 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id r39si673593qtb.2.2017.02.06.07.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 07:03:41 -0800 (PST)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v3 01/14] mm: thp: make __split_huge_pmd_locked visible.
Date: Mon, 06 Feb 2017 09:03:46 -0600
Message-ID: <C505CA58-64AF-4198-9CDF-58E623515D48@sent.com>
In-Reply-To: <20170206150224.GJ2267@bombadil.infradead.org>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-2-zi.yan@sent.com>
 <20170206150224.GJ2267@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_7EE1AB9B-B120-4C1C-B1C2-632C56E726FD_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_7EE1AB9B-B120-4C1C-B1C2-632C56E726FD_=
Content-Type: text/plain; markup=markdown

On 6 Feb 2017, at 9:02, Matthew Wilcox wrote:

> On Sun, Feb 05, 2017 at 11:12:39AM -0500, Zi Yan wrote:
>> +++ b/include/linux/huge_mm.h
>> @@ -120,6 +120,8 @@ static inline int split_huge_page(struct page *page)
>>  }
>>  void deferred_split_huge_page(struct page *page);
>>
>> +void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>> +		unsigned long haddr, bool freeze);
>
> Could you change that from 'haddr' to 'address' so callers who only
> read the header instead of the implementation aren't expecting to align
> it themselves?

Sure. I will do that to avoid confusion.

Thanks for pointing it out.


>
>> +void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>> +		unsigned long address, bool freeze)
>>  {
>>  	struct mm_struct *mm = vma->vm_mm;
>>  	struct page *page;


--
Best Regards
Yan Zi

--=_MailMate_7EE1AB9B-B120-4C1C-B1C2-632C56E726FD_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYmJBSAAoJEEGLLxGcTqbMcrUH/jJa89WsXKfmoKWxV5lrXwJz
zSe8GzpH6qY3KrKJnHYzoeMllbu5a5IwMK3sEA5W0DO9SnCFSnXXKE6laWAF/+hC
AQnFM/xeZYqFAWt4xWG4VQfBv0ULWhPjUIsa8Tr6YowVAZ37eW51YJuaVFcrslR9
xuqNZ85mVPjFUyyKxIEEgxH/GcgUyhSXF/+k3bFlDddXKmHN9yogbaZL3DPUE2Oy
4DcJay+G3IHOdFn2cJqRcIFfrwMLckiA+6zvoRCQGXJmM38AX/Cv/axz95kRUvjM
BNk35ItJ3q9duU+7mhru7d/9S9JpGpvpqz7K3pleint7Et1uj006RN7a+BFmwqk=
=Kibq
-----END PGP SIGNATURE-----

--=_MailMate_7EE1AB9B-B120-4C1C-B1C2-632C56E726FD_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
