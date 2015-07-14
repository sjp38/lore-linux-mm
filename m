Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3806B0261
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 05:06:37 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so2044987qkd.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:06:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s33si350764qge.49.2015.07.14.02.06.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 02:06:36 -0700 (PDT)
Message-ID: <55A4D110.2070103@redhat.com>
Date: Tue, 14 Jul 2015 11:06:24 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/36] THP refcounting redesign
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="avLne1GieRBlMITW4999kMSWxtOX2M621"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--avLne1GieRBlMITW4999kMSWxtOX2M621
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07/10/2015 07:41 PM, Kirill A. Shutemov wrote:
> Hello everybody,
>=20
=2E..
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcoun=
ting/v5
>=20

I guess you mean thp/refcounting/v8. Also you might want to add v8 to
the subject. Still on the cosmetic side, checkpatch.pl show quite a few
coding style errors and warnings. You'll make maintainer life easier by
running checkpatch on your serie.
On the content side: I've quickly tested this version without finding
any issue so far.

Thanks,
Jerome


--avLne1GieRBlMITW4999kMSWxtOX2M621
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVpNEVAAoJEHTzHJCtsuoC6DEIAKheAIMKCNu7Lkh3XS/SyP7Y
3IL2PEfOGJVifqY76mGiVtDnugAEE04wO4jLqj6uBG9Mq9yvLbj0FskkgBNs8U7a
Tj28NnP78Ii9uEusFt6Gu7U7Ycki9/5v4FBY+W2x4nMKB5Xc+WgpzLIIdNSY5PR6
MmlOWyHmqqhAV4jhhP1XPTqTvBfNSjNC9MU96YY7LyFVlxAjqMnNR5zL1n2U9Ekx
lL5SOyeHUkfAdaQCwoR3IkrnPZ6ekSrj/6b6uFZwE1X1g+8uqrzgLFpIADu2KorK
B3FGRP1KNp9QQhCXtznV1/p258bI/SsIqUzaDlMrj7n0/vr5FconvWlH8ki9vPg=
=KaP9
-----END PGP SIGNATURE-----

--avLne1GieRBlMITW4999kMSWxtOX2M621--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
