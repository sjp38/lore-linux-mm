Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 968226B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:38:06 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f11-v6so1197460otf.7
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:38:06 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r28-v6si8981267otb.299.2018.10.02.05.38.05
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 05:38:05 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <835085a2-79c2-4eb5-2c10-13bb2893f611@arm.com>
Date: Tue, 2 Oct 2018 13:38:01 +0100
MIME-Version: 1.0
In-Reply-To: <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Hi Anshuman

On 02/10/18 13:15, Anshuman Khandual wrote:
> Architectures like arm64 have PUD level HugeTLB pages for certain configs
> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
> enabled for migration. It can be achieved through checking for PUD_SHIFT
> order based HugeTLB pages during migration.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>   include/linux/hugetlb.h | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 6b68e34..9c1b77f 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -483,7 +483,8 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>   {
>   #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>   	if ((huge_page_shift(h) == PMD_SHIFT) ||
> -		(huge_page_shift(h) == PGDIR_SHIFT))
> +		(huge_page_shift(h) == PUD_SHIFT) ||


> +			(huge_page_shift(h) == PGDIR_SHIFT))

nit: Extra Tab ^^.
Also, if only arm64 supports PUD_SHIFT, should this be added only in the 
arm64 specific backend, which we introduce later ?

Suzuki
