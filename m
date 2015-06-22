Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4186B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 09:33:07 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so83127473qke.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 06:33:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b9si9471315qkh.16.2015.06.22.06.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 06:33:06 -0700 (PDT)
Message-ID: <55880E86.3000002@redhat.com>
Date: Mon, 22 Jun 2015 15:32:54 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv6 00/36] THP refcounting redesign
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <558021D9.4050304@redhat.com> <20150622132125.GG7934@node.dhcp.inet.fi>
In-Reply-To: <20150622132125.GG7934@node.dhcp.inet.fi>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="DCGagMPAxe45OLNEvMXkFK5Xuw7Nd4cfP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DCGagMPAxe45OLNEvMXkFK5Xuw7Nd4cfP
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 06/22/2015 03:21 PM, Kirill A. Shutemov wrote:
> On Tue, Jun 16, 2015 at 03:17:13PM +0200, Jerome Marchand wrote:
>> On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
>>> Hello everybody,
>>>
>>> Here's new revision of refcounting patchset. Please review and consid=
er
>>> applying.
>>>
>>> The goal of patchset is to make refcounting on THP pages cheaper with=

>>> simpler semantics and allow the same THP compound page to be mapped w=
ith
>>> PMD and PTEs. This is required to get reasonable THP-pagecache
>>> implementation.
>>>
>>> With the new refcounting design it's much easier to protect against
>>> split_huge_page(): simple reference on a page will make you the deal.=

>>> It makes gup_fast() implementation simpler and doesn't require
>>> special-case in futex code to handle tail THP pages.
>>>
>>> It should improve THP utilization over the system since splitting THP=
 in
>>> one process doesn't necessary lead to splitting the page in all other=

>>> processes have the page mapped.
>>>
>>> The patchset drastically lower complexity of get_page()/put_page()
>>> codepaths. I encourage people look on this code before-and-after to
>>> justify time budget on reviewing this patchset.
>>>
>>> =3D Changelog =3D
>>>
>>> v6:
>>>   - rebase to since-4.0;
>>>   - optimize mapcount handling: significantely reduce overhead for mo=
st
>>>     common cases.
>>>   - split pages on migrate_pages();
>>>   - remove infrastructure for handling splitting PMDs on all architec=
tures;
>>>   - fix page_mapcount() for hugetlb pages;
>>>
>>
>> Hi Kirill,
>>
>> I ran some LTP mm tests and hugemmap tests trigger the following:
>>
>> [  438.749457] page:ffffea0000df8000 count:2 mapcount:0 mapping:      =
    (null) index:0x0 compound_mapcount: 0
>> [  438.750089] flags: 0x3ffc0000004001(locked|head)
>> [  438.750089] page dumped because: VM_BUG_ON_PAGE(page_mapped(page))
>=20
> Did you run with original or updated version of patch 27/36?
> In original post of v6 there was bug: page_mapped() always returned tru=
e.
>=20

Indeed! I'll try again with the corrected patch.

Thanks,
Jerome




--DCGagMPAxe45OLNEvMXkFK5Xuw7Nd4cfP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJViA6KAAoJEHTzHJCtsuoCKpAH/2ETtZ0CobvPY8lHdJMNJRqS
UZwKi7NZKytqTyXTjaF81hIifTsEnejvXpifnHWAwdKEM+05bb6URBrmsVqGWbxs
s0U6ztNFpnR8SzRW4JIZXRNz5L17SbesWXUV0WCCHMlqYwUgmYKUp8jQh+uygxWu
HbkQBdWKshiFJBSX+ks2Qqq8DYNCJkoXs1gFAX/WXt8fiPHhGxQCKyklzTjT/w9P
1h8CANMjlxM/wiW1N3ooNIaxJuhLJ6DJF6hVhO++IdWVYwODIyvCMfFZ/VGqXH65
Qu88zk5nOH+BsA5UbRQc5ytE+X8PfOCWQm78fk8XfpwXtdVi5XyOdOEJX/a/CO4=
=FVxM
-----END PGP SIGNATURE-----

--DCGagMPAxe45OLNEvMXkFK5Xuw7Nd4cfP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
