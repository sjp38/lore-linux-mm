Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCBFE6B05D7
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:36:05 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id i1-v6so17463120wrr.18
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:36:05 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0072.outbound.protection.outlook.com. [104.47.0.72])
        by mx.google.com with ESMTPS id m1-v6si3005383wrp.29.2018.11.08.02.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Nov 2018 02:36:04 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 4/5] arm64/mm: Enable HugeTLB migration
Date: Thu, 8 Nov 2018 10:35:57 +0000
Message-ID: <20181108103545.c634kha6kpgpy34q@capper-debian.cambridge.arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-5-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1540299721-26484-5-git-send-email-anshuman.khandual@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1A8C0C0B04CEEA41863DB68C42ADF47C@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Suzuki Poulose <Suzuki.Poulose@arm.com>, Punit Agrawal <Punit.Agrawal@arm.com>, Will Deacon <Will.Deacon@arm.com>, Steven Price <Steven.Price@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, nd <nd@arm.com>

On Tue, Oct 23, 2018 at 06:32:00PM +0530, Anshuman Khandual wrote:
> Let arm64 subscribe to generic HugeTLB page migration framework. Right no=
w
> this only works on the following PMD and PUD level HugeTLB page sizes wit=
h
> various kernel base page size combinations.
>=20
>        CONT PTE    PMD    CONT PMD    PUD
>        --------    ---    --------    ---
> 4K:         NA     2M         NA      1G
> 16K:        NA    32M         NA
> 64K:        NA   512M         NA
>=20
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>


Reviewed-by: Steve Capper <steve.capper@arm.com>

> ---
>  arch/arm64/Kconfig | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index a8ae30f..4b3e269 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1331,6 +1331,10 @@ config SYSVIPC_COMPAT
>  	def_bool y
>  	depends on COMPAT && SYSVIPC
> =20
> +config ARCH_ENABLE_HUGEPAGE_MIGRATION
> +	def_bool y
> +	depends on HUGETLB_PAGE && MIGRATION
> +
>  menu "Power management options"
> =20
>  source "kernel/power/Kconfig"
> --=20
> 2.7.4
>=20
