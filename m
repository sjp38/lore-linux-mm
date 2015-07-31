Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5006B0257
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:07:03 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so47334738qge.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:07:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n8si6086930qhb.105.2015.07.31.08.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:07:02 -0700 (PDT)
Message-ID: <55BB8F0F.8040903@redhat.com>
Date: Fri, 31 Jul 2015 17:06:55 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 29/36] thp: implement split_huge_pmd()
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-30-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8nFvljaAp0CjsdUIwJx27nAJfuASFd0QU"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8nFvljaAp0CjsdUIwJx27nAJfuASFd0QU
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> Original split_huge_page() combined two operations: splitting PMDs into=

> tables of PTEs and splitting underlying compound page. This patch
> implements split_huge_pmd() which split given PMD without splitting
> other PMDs this page mapped with or underlying compound page.
>=20
> Without tail page refcounting, implementation of split_huge_pmd() is
> pretty straight-forward.

While it's significantly simpler than it used to be, straight-forward is
still not the adjective which come to my mind.

>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/huge_mm.h |  11 ++++-
>  mm/huge_memory.c        | 122 ++++++++++++++++++++++++++++++++++++++++=
++++++++
>  2 files changed, 132 insertions(+), 1 deletion(-)
>=20




--8nFvljaAp0CjsdUIwJx27nAJfuASFd0QU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu48PAAoJEHTzHJCtsuoCRhAH/2QSeBmuyAAmnvsuWEvNRwv2
KanZinUEiJb5yBpSyw98DueKKUtUTUUL9x75nHjXSqtEdHnCSAjl6GRHf+4Fgl9r
OQ9QF3NRVbE8q9OIZsO1/z9zucQGMVyNL+h2l94bBKHu0AEwTPyFoJnHcrNYoveu
9huL2kvVx51tenjt7W2PZV7uxT7LE9W+aBxckljf3oYWjy1CkggKt3KSE+LKh5nR
dlkkI6AevO2/TyT4sqkPyKfXCuEzoBKoicvibt5swwh86OIV7Tn3ek5KcWkZDnf5
B12EPRUSyXoXL0V2S8SDQz4Z9EN9AibW8o2rmrgO/rhyueH+aSQ6uYSUQ3ITydo=
=7suc
-----END PGP SIGNATURE-----

--8nFvljaAp0CjsdUIwJx27nAJfuASFd0QU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
