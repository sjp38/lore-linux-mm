Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id DE45C6B0255
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:53:07 -0400 (EDT)
Received: by qged69 with SMTP id d69so47224298qge.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:53:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j73si1733294qhc.99.2015.07.31.07.53.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:53:07 -0700 (PDT)
Message-ID: <55BB8BCC.9010302@redhat.com>
Date: Fri, 31 Jul 2015 16:53:00 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 15/36] ksm: prepare to new THP semantics
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-16-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="kKhNvW4erCkTUf2BsJmf9IHW2jStHUkLU"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kKhNvW4erCkTUf2BsJmf9IHW2jStHUkLU
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> We don't need special code to stabilize THP. If you've got reference to=

> any subpage of THP it will not be split under you.
>=20
> New split_huge_page() also accepts tail pages: no need in special code
> to get reference to head page.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/ksm.c | 57 ++++++++++----------------------------------------------=
-
>  1 file changed, 10 insertions(+), 47 deletions(-)
>=20


--kKhNvW4erCkTUf2BsJmf9IHW2jStHUkLU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4vMAAoJEHTzHJCtsuoC6MgIAJ21uWlVyFN04HuTAUFKB4LX
nNJqVBZtqTdwOppekN+QjQhABcQzRkNPbZ/D6ObPA1LlAsW9Olnkm35/WJB4kgRU
39KdoYanL+YMBhwAx+eBC683MUHnaTS349XEE6GGNm38hKsOO+3CNLCfYg+4yDjB
m3iRCIVzjlC72umI+5wb4M/Lu7YkG7zSOpyjNJY0dNJWclsaG5oz0NKpDIduuJlq
GQxv0fpnn9R5psVX6mdGHICrDpwyQMZNjAFn6LnO819cwR3WQwW4J9G6RAlVxWE6
SeOHLIUQjRxv6ORdrD6JHC4XGaA9Rv5r/ZHR4AfWJMgjfHa/QLoqXr3EXa/QT/A=
=f1VV
-----END PGP SIGNATURE-----

--kKhNvW4erCkTUf2BsJmf9IHW2jStHUkLU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
