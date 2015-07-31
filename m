Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id A442F6B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:52:27 -0400 (EDT)
Received: by qged69 with SMTP id d69so47208876qge.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:52:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4si6049946qge.81.2015.07.31.07.52.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:52:26 -0700 (PDT)
Message-ID: <55BB8BA4.5020702@redhat.com>
Date: Fri, 31 Jul 2015 16:52:20 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 14/36] futex, thp: remove special case for THP in get_futex_key
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-15-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="6TCgIiIpDEi7P02OdIaV9ppRbmDquRKv6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6TCgIiIpDEi7P02OdIaV9ppRbmDquRKv6
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> With new THP refcounting, we don't need tricks to stabilize huge page.
> If we've got reference to tail page, it can't split under us.
>=20
> This patch effectively reverts a5b338f2b0b1.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  kernel/futex.c | 61 ++++++++++++--------------------------------------=
--------
>  1 file changed, 12 insertions(+), 49 deletions(-)




--6TCgIiIpDEi7P02OdIaV9ppRbmDquRKv6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4ukAAoJEHTzHJCtsuoC2ZgH/3Y4UJr6S0vNauQ5GOvmVthk
3bzZuEixxFnzk23ZnhJcQBUJ77+aDzDW0GEUEwHcDSV40ksr6dcOlnfTtogx73p0
xIWOPwcMrSs3bjGbCX+S2riTvgJWHrpQo634XsgrVDDLQbswuvjKdShLETROK05s
8OM+aiyOVOmZxg0n0FoNTnJCeJ1oR3YhrVqmeWLUJiF1IbAxGbzPgNTsZ3Zyyw1Q
WegDn/DZ41UjTdYuYwAgiV01KAHy/ctPQtQ3IJtkcfSbFbkrMrz/+xK7bfu6gg0s
EAEevRlXxhsjzKN258ftn2uVPP3jfOpCbZ2bG9WBFfAmHw/D07PAameoEzv/9IY=
=bsQy
-----END PGP SIGNATURE-----

--6TCgIiIpDEi7P02OdIaV9ppRbmDquRKv6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
