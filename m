Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 282B16B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:09:45 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so30120687qkf.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:09:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b20si6157454qkh.3.2015.07.31.08.09.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:09:44 -0700 (PDT)
Message-ID: <55BB8FB2.6040004@redhat.com>
Date: Fri, 31 Jul 2015 17:09:38 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 30/36] thp: add option to setup migration entiries during
 PMD split
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-31-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="1DLOfwxWiXA2sjSHOVoUkPb5ihV8UQlHf"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1DLOfwxWiXA2sjSHOVoUkPb5ihV8UQlHf
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> We are going to use migration PTE entires to stabilize page counts.
> If the page is mapped with PMDs we need to split the PMD and setup
> migration enties. It's reasonable to combine these operations to avoid
> double-scanning over the page table.

Entries? Three different typos for three occurrences of the same word.
You don't like it, do you?

>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/huge_memory.c | 23 +++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)
>=20



--1DLOfwxWiXA2sjSHOVoUkPb5ihV8UQlHf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4+yAAoJEHTzHJCtsuoCrlAIAK8fh4KyYtG3dLWKObgWfN2V
goTeV5eMksF2UG04TtEXX500LAxr9LF7HjuowmoQhDt3KzLmXKopr7xH5eZ69U1P
F5/KHvJEsWWtJVgN5axnKqtvg+PKGPuuPqIl5OK3wlqX65kNlXoeYdiwe7ccnyQu
ilMNEKrKuR3yXInkhYZg1ldh+7hYC+xEZkIqxlMOqYTlFb/ajJUIw9+kepztrw1N
vsjbfQaS7y1A/zHQK5enUmQrc3jczQehcAddRj7xyxqiUibhGPZI6NbWGT1+QTlQ
0cCID4Vvi/qX5rnnmIWflCSpCniChLms92S89w8qfeAu4beVUZHQmm0Y+aB0nv4=
=l7RX
-----END PGP SIGNATURE-----

--1DLOfwxWiXA2sjSHOVoUkPb5ihV8UQlHf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
