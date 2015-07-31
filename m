Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 425CB6B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 10:46:50 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so47243241qge.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:46:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x75si5986445qha.126.2015.07.31.07.46.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 07:46:49 -0700 (PDT)
Message-ID: <55BB8A53.8090704@redhat.com>
Date: Fri, 31 Jul 2015 16:46:43 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 03/36] memcg: adjust to support new THP refcounting
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="tKKHwh4qmnIDIis1H5cVLgl3DRCpUc9Bc"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tKKHwh4qmnIDIis1H5cVLgl3DRCpUc9Bc
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> As with rmap, with new refcounting we cannot rely on PageTransHuge() to=

> check if we need to charge size of huge page form the cgroup. We need t=
o
> get information from caller to know whether it was mapped with PMD or
> PTE.
>=20
> We do uncharge when last reference on the page gone. At that point if w=
e
> see PageTransHuge() it means we need to unchange whole huge page.
>=20
> The tricky part is partial unmap -- when we try to unmap part of huge
> page. We don't do a special handing of this situation, meaning we don't=

> uncharge the part of huge page unless last user is gone or
> split_huge_page() is triggered. In case of cgroup memory pressure
> happens the partial unmapped page will be split through shrinker. This
> should be good enough.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/memcontrol.h | 16 +++++++-----
>  kernel/events/uprobes.c    |  7 +++---
>  mm/filemap.c               |  8 +++---
>  mm/huge_memory.c           | 33 ++++++++++++------------
>  mm/memcontrol.c            | 62 +++++++++++++++++---------------------=
--------
>  mm/memory.c                | 28 ++++++++++-----------
>  mm/shmem.c                 | 21 +++++++++-------
>  mm/swapfile.c              |  9 ++++---
>  mm/userfaultfd.c           |  6 ++---
>  9 files changed, 92 insertions(+), 98 deletions(-)



--tKKHwh4qmnIDIis1H5cVLgl3DRCpUc9Bc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu4pTAAoJEHTzHJCtsuoCVuUIAIvl1viUxIL1N9Q0y+ae2G6d
GS/t/a0v7D30pFVmlVPCU2sDUnfqG/loRM+2NooPp6AIUY8HY/JAJkD9M0nPibRp
t/UU44Gp3Ui7RnB30hrTJwra0ITuPwo3rAPoBurvqt/gHT6B2C6E6QjFA8Pqnklm
LBG7rYN5B+y3GVc2IGJWRsjAPWJwTi/TTlL9PCuFnTjfcIWe/Ce0S82LtMG3boGD
rDbBZ2XhONGh0oPJmIJTM4tSxt/EbuKtVlRLW645xO4aVKpgaxY3O2Ns9GwB3/Cl
/dO75pNjq2dKhJkwVLbVE12ovOtFCYUPgFqFDOyyf0Ezdwzatq/1/990NSpTsgE=
=WHtF
-----END PGP SIGNATURE-----

--tKKHwh4qmnIDIis1H5cVLgl3DRCpUc9Bc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
