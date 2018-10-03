Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0CF96B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 06:23:04 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id j12-v6so3438212ota.3
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 03:23:04 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f53si604908otd.29.2018.10.03.03.23.03
        for <linux-mm@kvack.org>;
        Wed, 03 Oct 2018 03:23:03 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <835085a2-79c2-4eb5-2c10-13bb2893f611@arm.com>
 <c0689b0c-4810-e0e8-354e-55c45d59b6d0@arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <a6b96126-5571-2aa2-6deb-09a457afd781@arm.com>
Date: Wed, 3 Oct 2018 11:22:59 +0100
MIME-Version: 1.0
In-Reply-To: <c0689b0c-4810-e0e8-354e-55c45d59b6d0@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 02/10/18 13:56, Anshuman Khandual wrote:
> 
> 
> On 10/02/2018 06:08 PM, Suzuki K Poulose wrote:
>> Hi Anshuman
>>
>> On 02/10/18 13:15, Anshuman Khandual wrote:
>>> Architectures like arm64 have PUD level HugeTLB pages for certain configs
>>> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
>>> enabled for migration. It can be achieved through checking for PUD_SHIFT
>>> order based HugeTLB pages during migration.
>>>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>>  A  include/linux/hugetlb.h | 3 ++-
>>>  A  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>>> index 6b68e34..9c1b77f 100644
>>> --- a/include/linux/hugetlb.h
>>> +++ b/include/linux/hugetlb.h
>>> @@ -483,7 +483,8 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>>>  A  {
>>>  A  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>>>  A A A A A  if ((huge_page_shift(h) == PMD_SHIFT) ||
>>> -A A A A A A A  (huge_page_shift(h) == PGDIR_SHIFT))
>>> +A A A A A A A  (huge_page_shift(h) == PUD_SHIFT) ||
>>
>>
>>> +A A A A A A A A A A A  (huge_page_shift(h) == PGDIR_SHIFT))
>>
>> nit: Extra Tab ^^.
> 
> The tab is in there when you apply this patch and all three checks are tab separated
> in a newline.

Well, with the patch applied, at least I can see 2 tabs for the
PUD_SHIFT check and 3 tabs for PGDIR_SHIFT check. Which seems
inconsistent. Is it just me (my mail client) ?

Suzuki
