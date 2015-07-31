Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id AFABD6B0254
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:47:50 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so47265931qge.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:47:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 21si6023574qhh.47.2015.07.31.07.47.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:47:50 -0700 (PDT)
Message-ID: <55BB8A8F.9080504@redhat.com>
Date: Fri, 31 Jul 2015 16:47:43 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 05/36] mm: adjust FOLL_SPLIT for new refcounting
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-6-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="FBbngEo5wk9wTBSbfBEsnErjG8RhlaaM5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FBbngEo5wk9wTBSbfBEsnErjG8RhlaaM5
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> We need to prepare kernel to allow transhuge pages to be mapped with
> ptes too. We need to handle FOLL_SPLIT in follow_page_pte().
>=20
> Also we use split_huge_page() directly instead of split_huge_page_pmd()=
=2E
> split_huge_page_pmd() will gone.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/gup.c | 67 +++++++++++++++++++++++++++++++++++++++++++++++---------=
--------
>  1 file changed, 49 insertions(+), 18 deletions(-)
>=20



--FBbngEo5wk9wTBSbfBEsnErjG8RhlaaM5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4qPAAoJEHTzHJCtsuoCDKsIAJeSWO/ooM3Fl1ziG0wgOcaU
rSsdlbnH0vi+AWh03ILFxZhY9/mz95YZT3xyn52AzKnvqeQZR740lxUQsCp+uD3v
tyqFapPOVAt5grg7Jq8k2tNAZGKdknvlXwWPn0Z6CmfzxwjwngxT/d1Dx7Q6T3T3
8WwHUAQ5hD8agym5nWfS58q+j1BRMvMH6apC6gXqVaVjpAEE0K6O+4blgreBYUkh
6P++ZqJjAUZrPD690PeoK7+W49FwJ7o6s3jJ9YvmbuGTOXyTeBIUfUE38NqWV0ZF
9W3ECUbznkGjV2pocgQn1wTKLMUbZP0uYDT1KDd1YoR2byGU0T/9TFLCo52eTTo=
=tQCl
-----END PGP SIGNATURE-----

--FBbngEo5wk9wTBSbfBEsnErjG8RhlaaM5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
