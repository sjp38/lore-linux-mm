Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE466B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:54:09 -0400 (EDT)
Received: by qged69 with SMTP id d69so47247882qge.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:54:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 143si6057833qhc.39.2015.07.31.07.54.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:54:08 -0700 (PDT)
Message-ID: <55BB8C08.2020703@redhat.com>
Date: Fri, 31 Jul 2015 16:54:00 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 24/36] x86, thp: remove infrastructure for handling
 splitting PMDs
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-25-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Xf0nt0n0k5xHkn7aMwa7J6jEfHttWtrhF"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Xf0nt0n0k5xHkn7aMwa7J6jEfHttWtrhF
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> With new refcounting we don't need to mark PMDs splitting. Let's drop
> code to handle this.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  arch/x86/include/asm/pgtable.h       |  9 ---------
>  arch/x86/include/asm/pgtable_types.h |  2 --
>  arch/x86/mm/gup.c                    | 13 +------------
>  arch/x86/mm/pgtable.c                | 14 --------------
>  4 files changed, 1 insertion(+), 37 deletions(-)
>=20




--Xf0nt0n0k5xHkn7aMwa7J6jEfHttWtrhF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4wIAAoJEHTzHJCtsuoCDUUH/RhsveutTzPiscOpQGXiheLD
R+lwn4W0R52eU+eRcPexij83wGqKbz4G2HYrrF5kOD2hfFPhylGGsxUVIgL81UFH
XC+kYDM2/5C8cesGYE3jsgadjIMmIsUYoYZJSr8NoAsHLXBOsQAbvq6m85OUhlfV
TKP84J243rIqxvv+3I+7djM2IJnFI5+ZZpAU5l7huLWdaXf14+b127JQnsueU3kd
2q+bhGOc68ytJ2WXXYApBOWEh/jkWudCBX5U7xHlmLsKJZPv3iZlldr1IDjAzS51
yvPzAPLpilQd2bb+Zc43lt94guEzAe6aT0/lPUsABCOq8ZI5Oc0RKcQoUIXJ1Cc=
=7ket
-----END PGP SIGNATURE-----

--Xf0nt0n0k5xHkn7aMwa7J6jEfHttWtrhF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
