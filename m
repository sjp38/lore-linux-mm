Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD036B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:53:30 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so29930646qkf.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:53:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y39si6057978qgy.79.2015.07.31.07.53.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:53:29 -0700 (PDT)
Message-ID: <55BB8BE2.7080207@redhat.com>
Date: Fri, 31 Jul 2015 16:53:22 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 16/36] mm, thp: remove compound_lock
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-17-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lIgPQ8TRuSwRmqWnRfhHG1hJUorsX5BdE"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lIgPQ8TRuSwRmqWnRfhHG1hJUorsX5BdE
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> We are going to use migration entries to stabilize page counts. It mean=
s
> we don't need compound_lock() for that.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/mm.h         | 35 -----------------------------------
>  include/linux/page-flags.h | 12 +-----------
>  mm/debug.c                 |  3 ---
>  mm/memcontrol.c            | 11 +++--------
>  4 files changed, 4 insertions(+), 57 deletions(-)
>=20



--lIgPQ8TRuSwRmqWnRfhHG1hJUorsX5BdE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4viAAoJEHTzHJCtsuoCmkwH/j78pFXMVd0TPXDqbb0i7o2m
jxiQoHGkaB2GlR224Zw6bOIBLo82x6m0zuUprHETNK9e9kE0fTBz7SokqsaQt3Qy
e0GBuS/N+TsZNRpfMNNhv7ess5OzHETISArDpP/UJTSpfXP6+iqhJ3rhKEEdFXNG
ITFyEwTRw+M5grDWC2zk/lsHKFPcr9yqGmuCTdM65LDZZz54Km3XYk79jPO+Iy77
i6Dmi8P5ZDTyAWW8QFZnveY2ACPZ8Z8MgWXJcOtPWxmE2TZaKrGMSqm09bRQfAcd
M9KOwYDPjNbfw86SFw2faTtXZGjb95JeBG7VSJMW5yAW3Up/E0nAmMf7KkBrZVk=
=6wfk
-----END PGP SIGNATURE-----

--lIgPQ8TRuSwRmqWnRfhHG1hJUorsX5BdE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
