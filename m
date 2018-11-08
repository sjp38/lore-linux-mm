Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 817D66B05D3
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:34:24 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id c16-v6so17491098wrr.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:34:24 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0086.outbound.protection.outlook.com. [104.47.0.86])
        by mx.google.com with ESMTPS id p2-v6si3026812wra.67.2018.11.08.02.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Nov 2018 02:34:23 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 2/5] mm/hugetlb: Enable PUD level huge page migration
Date: Thu, 8 Nov 2018 10:34:21 +0000
Message-ID: <20181108103409.35r77mgtpigs5q3b@capper-debian.cambridge.arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-3-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1540299721-26484-3-git-send-email-anshuman.khandual@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <27B9F2B55EC4F04BB017B9675CDA0971@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Suzuki Poulose <Suzuki.Poulose@arm.com>, Punit Agrawal <Punit.Agrawal@arm.com>, Will Deacon <Will.Deacon@arm.com>, Steven Price <Steven.Price@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, nd <nd@arm.com>

On Tue, Oct 23, 2018 at 06:31:58PM +0530, Anshuman Khandual wrote:
> Architectures like arm64 have PUD level HugeTLB pages for certain configs
> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
> enabled for migration. It can be achieved through checking for PUD_SHIFT
> order based HugeTLB pages during migration.
>=20
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Reviewed-by: Steve Capper <steve.capper@arm.com>

> ---
>  include/linux/hugetlb.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 1b858d7..70bcd89 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -497,7 +497,8 @@ static inline bool hugepage_migration_supported(struc=
t hstate *h)
>  {
>  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	if ((huge_page_shift(h) =3D=3D PMD_SHIFT) ||
> -		(huge_page_shift(h) =3D=3D PGDIR_SHIFT))
> +		(huge_page_shift(h) =3D=3D PUD_SHIFT) ||
> +			(huge_page_shift(h) =3D=3D PGDIR_SHIFT))
>  		return true;
>  	else
>  		return false;
> --=20
> 2.7.4
>=20
