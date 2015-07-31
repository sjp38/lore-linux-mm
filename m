Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id C09306B0259
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:14:41 -0400 (EDT)
Received: by qgii95 with SMTP id i95so47666959qgi.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:14:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si6169885qkx.26.2015.07.31.08.14.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:14:41 -0700 (PDT)
Message-ID: <55BB90DA.8050603@redhat.com>
Date: Fri, 31 Jul 2015 17:14:34 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 33/36] migrate_pages: try to split pages on qeueuing
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-34-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="ucEcmhgRqcj04BE6n4irXUn6OUM3x8nma"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ucEcmhgRqcj04BE6n4irXUn6OUM3x8nma
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> We are not able to migrate THPs. It means it's not enough to split only=

> PMD on migration -- we need to split compound page under it too.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/mempolicy.c | 37 +++++++++++++++++++++++++++++++++----
>  1 file changed, 33 insertions(+), 4 deletions(-)
>=20




--ucEcmhgRqcj04BE6n4irXUn6OUM3x8nma
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu5DaAAoJEHTzHJCtsuoCppIIAIeTrdGnIdHt8N3BUIHzu+CM
VydsymaViOWTTcNPzD0RnGwuOp9GahTCP3Kbrz4hwCwWqincVwqUZ26Bqaz4KLTr
1Dse6rwuJcJGoeeytlOYnsgGcb8W9QPMjlCdbg/ZEqoCtxBkgs3vc2W4aPN0BEba
Rb4K2RWzYFo5jXr5/RNjZea0b8Equz1YLsW4ZwTp16W6jxah9BHg+QVVZGl6dfrl
bntfX7s99wHMJBv/bOUxZAZ/oDVHKYYGa0CVaXjiTlApCqoBNnuIPPwljUi2SsJ5
WsLY0Lc4/87keTzDQkpelYfFgMwKjR9LHx6yQhXjjfdB96buEb+xOA5hKIAU4cE=
=8xVF
-----END PGP SIGNATURE-----

--ucEcmhgRqcj04BE6n4irXUn6OUM3x8nma--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
