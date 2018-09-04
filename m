Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89CE56B6DD3
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 10:00:29 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l11-v6so2367072qkk.0
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 07:00:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f47-v6sor9542184qta.144.2018.09.04.07.00.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 07:00:28 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: hugepage: mark splitted page dirty when needed
Date: Tue, 04 Sep 2018 10:00:28 -0400
Message-ID: <D3B32B41-61D5-47B3-B1FC-77B0F71ADA47@cs.rutgers.edu>
In-Reply-To: <20180904080115.o2zj4mlo7yzjdqfl@kshutemo-mobl1>
References: <20180904075510.22338-1-peterx@redhat.com>
 <20180904080115.o2zj4mlo7yzjdqfl@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_00AD4CDF-164D-44D4-9FF2-9BB7F3A78B9B_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_00AD4CDF-164D-44D4-9FF2-9BB7F3A78B9B_=
Content-Type: text/plain

On 4 Sep 2018, at 4:01, Kirill A. Shutemov wrote:

> On Tue, Sep 04, 2018 at 03:55:10PM +0800, Peter Xu wrote:
>> When splitting a huge page, we should set all small pages as dirty if
>> the original huge page has the dirty bit set before.  Otherwise we'll
>> lose the original dirty bit.
>
> We don't lose it. It got transfered to struct page flag:
>
> 	if (pmd_dirty(old_pmd))
> 		SetPageDirty(page);
>

Plus, when split_huge_page_to_list() splits a THP, its subroutine __split_huge_page()
propagates the dirty bit in the head page flag to all subpages in __split_huge_page_tail().

--
Best Regards
Yan Zi

--=_MailMate_00AD4CDF-164D-44D4-9FF2-9BB7F3A78B9B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJbjo/8AAoJEEGLLxGcTqbMOQwH/0Dqm8efQO5JjwZLEfJ72RER
Hi/IEMJNxCdcWacrHwUTlEcDc8Si36b83nU5ja0FZLMtT6erIFoprzPcY+0AeMkP
FIoDqREsQUd/1rZS5/w5xzWZP53tBKXGwJ3Du6r2OFv11+O+UdGPFBTgRMafg15h
dZ1UPQ+gZWV0jJ5/BDwHVkA7fLSKvOwlLKeIUOonaOZI/WkU7VA7jT3TAoaZPvYD
W9rf4JmEY0aZi69K5krMidhXTvn7o5GQ0f7bLrXWuxGDtlDCsZWGwrTpTTOSPomM
mJ8Nf85vsXdUwkM0VAtMcARJ4EffLfaN1OdNeXxh/7stS8x85jo81OWNEGSdXaU=
=I4oJ
-----END PGP SIGNATURE-----

--=_MailMate_00AD4CDF-164D-44D4-9FF2-9BB7F3A78B9B_=--
