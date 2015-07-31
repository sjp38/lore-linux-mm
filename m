Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2366B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:45:34 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so47213723qge.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:45:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f8si5989285qhc.106.2015.07.31.07.45.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:45:33 -0700 (PDT)
Message-ID: <55BB8A00.4070509@redhat.com>
Date: Fri, 31 Jul 2015 16:45:20 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 02/36] rmap: add argument to charge compound page
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="mM5Rd0JOMFwAQebSdxtu0nR9AUuWk12Qc"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mM5Rd0JOMFwAQebSdxtu0nR9AUuWk12Qc
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound
> page. It means we cannot rely on PageTransHuge() check to decide if
> map/unmap small page or THP.
>=20
> The patch adds new argument to rmap functions to indicate whether we wa=
nt
> to operate on whole compound page or only the small page.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/rmap.h    | 12 +++++++++---
>  kernel/events/uprobes.c |  4 ++--
>  mm/huge_memory.c        | 16 ++++++++--------
>  mm/hugetlb.c            |  4 ++--
>  mm/ksm.c                |  4 ++--
>  mm/memory.c             | 14 +++++++-------
>  mm/migrate.c            |  8 ++++----
>  mm/rmap.c               | 48 +++++++++++++++++++++++++++++++----------=
-------
>  mm/swapfile.c           |  4 ++--
>  mm/userfaultfd.c        |  2 +-
>  10 files changed, 68 insertions(+), 48 deletions(-)



--mM5Rd0JOMFwAQebSdxtu0nR9AUuWk12Qc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4oFAAoJEHTzHJCtsuoCfqUH/ip6+HMzOwxmX5vsXDY3PKzL
krZNDHpXA3m1NlbxiApfNeAu8raV33MQx4b4IJHKL7Q+8cnTSjtTp7LwqBCqGhLx
ufi2ORxU6Xo1ogISd6A2JCyiSlKfYzBAAqEu53peFdEOWE/1Wr4UPZpUMPHelipm
c6QedVQ5eqRjpxWkcSun5hp+5AKUGwkNQC92qNCyV5ZKTe2ogDfSJPaBLy96Q2T8
kyJwzyOXWzAE1onAJY+q3jaKkh0xI81kvEZKvAXQ2tVrRqCP4LP2WOqCJhZAbGE4
ajDXMDBosUTzOfQZr+LTK3SqVKu5HJ/UHo9PgtEtVMF8TX882XimpXwgOCsj1PE=
=9Dxr
-----END PGP SIGNATURE-----

--mM5Rd0JOMFwAQebSdxtu0nR9AUuWk12Qc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
