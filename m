Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40ED46B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:26:55 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c3-v6so10569405qkb.2
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:26:55 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id n85-v6si404751qke.353.2018.06.29.11.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 11:26:53 -0700 (PDT)
Message-ID: <1530296809.16379.9.camel@surriel.com>
Subject: Re: [PATCH] mm: thp: passing correct vm_flags to hugepage_vma_check
From: Rik van Riel <riel@surriel.com>
Date: Fri, 29 Jun 2018 14:26:49 -0400
In-Reply-To: <20180629181752.792831-1-songliubraving@fb.com>
References: <20180629181752.792831-1-songliubraving@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-2/61GnD0D2WWFYIK2zJ9"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Song Liu <songliubraving@fb.com>, linux-mm@kvack.org
Cc: kernel-team@fb.com, Yang Shi <yang.shi@linux.alibaba.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>


--=-2/61GnD0D2WWFYIK2zJ9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2018-06-29 at 11:17 -0700, Song Liu wrote:

> To my surprise, after I thought we all agreed on v3 of the work.
> Yang's
> patch, which is similar to correct looking (but wrong) v1, got
> applied.
> So we still have the issue of stale vma->vm_flags. This patch fixes
> this
> issue. Please apply.
>=20
> Fixes: 02b75dc8160d ("mm: thp: register mm for khugepaged when
> merging vma for shmem")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
>=20
Reviewed-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.
--=-2/61GnD0D2WWFYIK2zJ9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAls2eekACgkQznnekoTE
3oOBogf/eqAjqSZK2qrWkZbIBaFF/BcJyak8oF8YTOU1eo4wqQ5xjOkOuSLCdoKe
9g+6Vpyjnj7vDIIUyC445qc5W5MsKyebMC7N2uON9KIKASLe6/S8Q9JI6YQ/WH+6
GybU9XIJQ1EMwYdAKBhjY8mpCjukWrnBtm9u3VMNyaOxEUvb2u3UNsUnFxdfRq23
oatEV9chmREl1DHQDQFAI18+taCwDSTShZC/hQJS3JQzjgtkPqX0lFqbPjeVhpoA
UI4gGy6EA36pwfqRIC2BVYPFY9NB6XrwpjgreRGqmJE12LiHtMDz+Cu+DXKbr0lM
xawxPadkCo5ZUCJ39rFopo8d3D4S5Q==
=qfnh
-----END PGP SIGNATURE-----

--=-2/61GnD0D2WWFYIK2zJ9--
