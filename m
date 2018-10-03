Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3216B0269
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 07:10:35 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id t3-v6so3316440oif.20
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 04:10:35 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a11si488897otk.257.2018.10.03.04.10.34
        for <linux-mm@kvack.org>;
        Wed, 03 Oct 2018 04:10:34 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <835085a2-79c2-4eb5-2c10-13bb2893f611@arm.com>
 <c0689b0c-4810-e0e8-354e-55c45d59b6d0@arm.com>
 <a6b96126-5571-2aa2-6deb-09a457afd781@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bad51030-5f02-4fc9-741c-0fffbd690aca@arm.com>
Date: Wed, 3 Oct 2018 16:40:27 +0530
MIME-Version: 1.0
In-Reply-To: <a6b96126-5571-2aa2-6deb-09a457afd781@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki K Poulose <suzuki.poulose@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/03/2018 03:52 PM, Suzuki K Poulose wrote:
> 
> 
> On 02/10/18 13:56, Anshuman Khandual wrote:
>>
>>
>> On 10/02/2018 06:08 PM, Suzuki K Poulose wrote:
>>> Hi Anshuman
>>>
>>> On 02/10/18 13:15, Anshuman Khandual wrote:
>>>> Architectures like arm64 have PUD level HugeTLB pages for certain configs
>>>> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
>>>> enabled for migration. It can be achieved through checking for PUD_SHIFT
>>>> order based HugeTLB pages during migration.
>>>>
>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>> ---
>>>> A A  include/linux/hugetlb.h | 3 ++-
>>>> A A  1 file changed, 2 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>>>> index 6b68e34..9c1b77f 100644
>>>> --- a/include/linux/hugetlb.h
>>>> +++ b/include/linux/hugetlb.h
>>>> @@ -483,7 +483,8 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>>>> A A  {
>>>> A A  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>>>> A A A A A A  if ((huge_page_shift(h) == PMD_SHIFT) ||
>>>> -A A A A A A A  (huge_page_shift(h) == PGDIR_SHIFT))
>>>> +A A A A A A A  (huge_page_shift(h) == PUD_SHIFT) ||
>>>
>>>
>>>> +A A A A A A A A A A A  (huge_page_shift(h) == PGDIR_SHIFT))
>>>
>>> nit: Extra Tab ^^.
>>
>> The tab is in there when you apply this patch and all three checks are tab separated
>> in a newline.
> 
> Well, with the patch applied, at least I can see 2 tabs for the
> PUD_SHIFT check and 3 tabs for PGDIR_SHIFT check. Which seems
> inconsistent. Is it just me (my mail client) ?

I am sorry, you are right. Did not understand your point earlier. Yeah there is
increasing number of tabs for each new line with a conditional check. Is there
a problem with this style of indentation ? Though I will be happy to change.
