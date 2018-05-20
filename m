Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EDB246B0006
	for <linux-mm@kvack.org>; Sun, 20 May 2018 19:26:31 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 7-v6so9002860oin.16
        for <linux-mm@kvack.org>; Sun, 20 May 2018 16:26:31 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id d36-v6si4945891otd.318.2018.05.20.16.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 16:26:31 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] MAINTAINERS: Change hugetlbfs maintainer and update
 files
Date: Sun, 20 May 2018 23:23:52 +0000
Message-ID: <20180520232352.GA7925@hori1.linux.bs1.fc.nec.co.jp>
References: <20180518225236.19079-1-mike.kravetz@oracle.com>
In-Reply-To: <20180518225236.19079-1-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D04C778E8AF1AA4A9AF674E22FB7FA72@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>

On Fri, May 18, 2018 at 03:52:36PM -0700, Mike Kravetz wrote:
> The current hugetlbfs maintainer has not been active for more than
> a few years.  I have been been active in this area for more than
> two years and plan to remain active in the foreseeable future.
>=20
> Also, update the hugetlbfs entry to include linux-mm mail list and
> additional hugetlbfs related files.  hugetlb.c and hugetlb.h are
> not 100% hugetlbfs, but a majority of their content is hugetlbfs
> related.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Thank you for taking responsibility on this!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  MAINTAINERS | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 9051a9ca24a2..c7a5eb074eb1 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6564,9 +6564,15 @@ F:	Documentation/networking/hinic.txt
>  F:	drivers/net/ethernet/huawei/hinic/
> =20
>  HUGETLB FILESYSTEM
> -M:	Nadia Yvette Chambers <nyc@holomorphy.com>
> +M:	Mike Kravetz <mike.kravetz@oracle.com>
> +L:	linux-mm@kvack.org
>  S:	Maintained
>  F:	fs/hugetlbfs/
> +F:	mm/hugetlb.c
> +F:	include/linux/hugetlb.h
> +F:	Documentation/admin-guide/mm/hugetlbpage.rst
> +F:	Documentation/vm/hugetlbfs_reserv.rst
> +F:	Documentation/ABI/testing/sysfs-kernel-mm-hugepages
> =20
>  HVA ST MEDIA DRIVER
>  M:	Jean-Christophe Trotin <jean-christophe.trotin@st.com>
> --=20
> 2.13.6
>=20
> =
