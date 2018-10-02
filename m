Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72EC36B0006
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:56:56 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id y68-v6so1157170oie.21
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:56:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f12si2067600oti.282.2018.10.02.05.56.55
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 05:56:55 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <835085a2-79c2-4eb5-2c10-13bb2893f611@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c0689b0c-4810-e0e8-354e-55c45d59b6d0@arm.com>
Date: Tue, 2 Oct 2018 18:26:49 +0530
MIME-Version: 1.0
In-Reply-To: <835085a2-79c2-4eb5-2c10-13bb2893f611@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki K Poulose <suzuki.poulose@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/02/2018 06:08 PM, Suzuki K Poulose wrote:
> Hi Anshuman
> 
> On 02/10/18 13:15, Anshuman Khandual wrote:
>> Architectures like arm64 have PUD level HugeTLB pages for certain configs
>> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
>> enabled for migration. It can be achieved through checking for PUD_SHIFT
>> order based HugeTLB pages during migration.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> A  include/linux/hugetlb.h | 3 ++-
>> A  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 6b68e34..9c1b77f 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -483,7 +483,8 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>> A  {
>> A  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>> A A A A A  if ((huge_page_shift(h) == PMD_SHIFT) ||
>> -A A A A A A A  (huge_page_shift(h) == PGDIR_SHIFT))
>> +A A A A A A A  (huge_page_shift(h) == PUD_SHIFT) ||
> 
> 
>> +A A A A A A A A A A A  (huge_page_shift(h) == PGDIR_SHIFT))
> 
> nit: Extra Tab ^^.

The tab is in there when you apply this patch and all three checks are tab separated
in a newline.

> Also, if only arm64 supports PUD_SHIFT, should this be added only in the arm64 specific backend, which we introduce later ?

Even if with the platform can add this up in the back end, I would think having this
on for default fall back function makes it complete.
