Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4B706B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 22:32:34 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id o6-v6so22231050oib.9
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:32:34 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t88-v6si10666867oij.53.2018.10.18.19.32.33
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 19:32:33 -0700 (PDT)
Subject: Re: [PATCH V2 2/5] mm/hugetlb: Distinguish between migratability and
 movability
References: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
 <1539316799-6064-3-git-send-email-anshuman.khandual@arm.com>
 <20181019015931.GA18973@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <e7a3d5d8-dc65-72fc-5764-010af02d1517@arm.com>
Date: Fri, 19 Oct 2018 08:02:26 +0530
MIME-Version: 1.0
In-Reply-To: <20181019015931.GA18973@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "suzuki.poulose@arm.com" <suzuki.poulose@arm.com>, "punit.agrawal@arm.com" <punit.agrawal@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Steven.Price@arm.com" <Steven.Price@arm.com>, "steve.capper@arm.com" <steve.capper@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>



On 10/19/2018 07:29 AM, Naoya Horiguchi wrote:
> On Fri, Oct 12, 2018 at 09:29:56AM +0530, Anshuman Khandual wrote:
>> During huge page allocation it's migratability is checked to determine if
>> it should be placed under movable zones with GFP_HIGHUSER_MOVABLE. But the
>> movability aspect of the huge page could depend on other factors than just
>> migratability. Movability in itself is a distinct property which should not
>> be tied with migratability alone.
>>
>> This differentiates these two and implements an enhanced movability check
>> which also considers huge page size to determine if it is feasible to be
>> placed under a movable zone. At present it just checks for gigantic pages
>> but going forward it can incorporate other enhanced checks.
> 
> (nitpicking...)
> The following code just checks hugepage_migration_supported(), so maybe
> s/Movability/Migratability/ is expected in the comment?
> 
>   static int unmap_and_move_huge_page(...)
>   {
>           ...
>           /*
>            * Movability of hugepages depends on architectures and hugepage size.
>            * This check is necessary because some callers of hugepage migration
>            * like soft offline and memory hotremove don't walk through page
>            * tables or check whether the hugepage is pmd-based or not before
>            * kicking migration.
>            */
>           if (!hugepage_migration_supported(page_hstate(hpage))) {
> 
Sure, will update this patch only unless other changes are suggested.
