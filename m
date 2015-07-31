Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E08DC6B0255
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:51:03 -0400 (EDT)
Received: by qgii95 with SMTP id i95so47126631qgi.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:51:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p75si6032418qgp.114.2015.07.31.07.51.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:51:03 -0700 (PDT)
Message-ID: <55BB8B50.1090000@redhat.com>
Date: Fri, 31 Jul 2015 16:50:56 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 12/36] thp: drop all split_huge_page()-related code
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-13-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="NCMTS7vAUEKpRsVbqh3BCBtFpXtq0Tkav"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--NCMTS7vAUEKpRsVbqh3BCBtFpXtq0Tkav
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> We will re-introduce new version with new refcounting later in patchset=
=2E
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/huge_mm.h |  28 +---
>  mm/huge_memory.c        | 400 +---------------------------------------=
--------
>  2 files changed, 7 insertions(+), 421 deletions(-)
>=20




--NCMTS7vAUEKpRsVbqh3BCBtFpXtq0Tkav
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4tQAAoJEHTzHJCtsuoCGkEH/jR8GFvuMDF8S8rJ1qWNoPrl
EpKJ6bqtq2ubDNLIfvmvWRS5ms86CRCzXgz/7jy0dY6uI1O1ZGStG24wnQ/4xSuP
PUoXRiEOFeSpTVlPJpOMWcndTw95NxNh4wmxu8EnzgJOCbSjDVEUbVbJLw+m4glZ
WB4V82ARrCAJx/7/tUDS2alhDN+oRc21ugyEBX3cmQdaRrg1/jEHN4mOp12cjmm/
CQ1ErLKgVdx2cZZjxzOQFMPwfNkNChUuphW0V/kpviOVdat9SDKxmU9WxUod2ITt
+9px583bntDViHhjHmnjHLgrb0pcbCx0bC/UQtdLOVQ0YKZhZPGeKki8MNmV6SU=
=Egt0
-----END PGP SIGNATURE-----

--NCMTS7vAUEKpRsVbqh3BCBtFpXtq0Tkav--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
