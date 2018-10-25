Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 300CE6B0007
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 02:23:45 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q23so5286620otl.1
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 23:23:45 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k44si3093443otk.44.2018.10.24.23.23.44
        for <linux-mm@kvack.org>;
        Wed, 24 Oct 2018 23:23:44 -0700 (PDT)
Subject: Re: [PATCH V3 3/5] mm/hugetlb: Enable arch specific huge page size
 support for migration
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-4-git-send-email-anshuman.khandual@arm.com>
 <20181024135639.GH18839@dhcp22.suse.cz>
 <20181024135859.GI18839@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bf5e636c-9cc4-50d6-4160-78a1a7703860@arm.com>
Date: Thu, 25 Oct 2018 11:53:34 +0530
MIME-Version: 1.0
In-Reply-To: <20181024135859.GI18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/24/2018 07:28 PM, Michal Hocko wrote:
> On Wed 24-10-18 15:56:39, Michal Hocko wrote:
>> On Tue 23-10-18 18:31:59, Anshuman Khandual wrote:
>>> Architectures like arm64 have HugeTLB page sizes which are different than
>>> generic sizes at PMD, PUD, PGD level and implemented via contiguous bits.
>>> At present these special size HugeTLB pages cannot be identified through
>>> macros like (PMD|PUD|PGDIR)_SHIFT and hence chosen not be migrated.
>>>
>>> Enabling migration support for these special HugeTLB page sizes along with
>>> the generic ones (PMD|PUD|PGD) would require identifying all of them on a
>>> given platform. A platform specific hook can precisely enumerate all huge
>>> page sizes supported for migration. Instead of comparing against standard
>>> huge page orders let hugetlb_migration_support() function call a platform
>>> hook arch_hugetlb_migration_support(). Default definition for the platform
>>> hook maintains existing semantics which checks standard huge page order.
>>> But an architecture can choose to override the default and provide support
>>> for a comprehensive set of huge page sizes.
>>>
>>> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>
>> Acked-by: Michal Hocko <mhocko@use.com>
> 
> fat fingers here, should be mhocko@suse.com of course.

Sure no problems. As we had discussed earlier and agreed to keep the previous
patch "mm/hugetlb: Enable PUD level huge page migration" separate and not fold
into this one, I will assume your ACK on it as well unless your disagree.
