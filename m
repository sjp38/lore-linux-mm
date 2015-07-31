Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4511C6B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:16:38 -0400 (EDT)
Received: by qgii95 with SMTP id i95so47709206qgi.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:16:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 140si6135010qhb.84.2015.07.31.08.16.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:16:37 -0700 (PDT)
Message-ID: <55BB914F.2000700@redhat.com>
Date: Fri, 31 Jul 2015 17:16:31 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 36/36] thp: update documentation
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-37-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-37-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lMh4KjPuqilvH9jcILTTPwWojnatckbfB"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lMh4KjPuqilvH9jcILTTPwWojnatckbfB
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> The patch updates Documentation/vm/transhuge.txt to reflect changes in
> THP design.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  Documentation/vm/transhuge.txt | 151 ++++++++++++++++++++++++++-------=
--------
>  1 file changed, 96 insertions(+), 55 deletions(-)
>=20



--lMh4KjPuqilvH9jcILTTPwWojnatckbfB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu5FPAAoJEHTzHJCtsuoCcaoH/2c+02dYPc7gfuiQ/zb4img8
PrKJsvNAVvlA38Otl4jyYonJcgujW3y04GbcChNeZXOWd9E4/hM/qi62G/AxxCST
hoyKbGcpl25/ybcEvHSYASDeg3gAqQfZVa/X2kTcvmm7GQdhcfGreokdJMHSwy+1
sLp0d6061com5NT4w46xgRsB/K0ggJMqZChABhobNwPfQsl/Ss8HJnZiNv2RMPvN
o+51odrsm1sgn6nCaZNYR23vGUK7ybLN2669cS5242St4JUakSICeKpIJvvKwMYg
ruU+pNdWjV0Hj5TNXPlcKgcmB2kDeAs9NREDJCX1Xb/mKdneqY6ZHpXCdz6dBCk=
=2Wf5
-----END PGP SIGNATURE-----

--lMh4KjPuqilvH9jcILTTPwWojnatckbfB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
