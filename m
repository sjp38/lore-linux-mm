Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B81D76B0003
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 03:45:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h48-v6so4208153edh.22
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 00:45:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l21-v6si542724ejs.32.2018.10.25.00.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 00:45:33 -0700 (PDT)
Date: Thu, 25 Oct 2018 09:45:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 3/5] mm/hugetlb: Enable arch specific huge page size
 support for migration
Message-ID: <20181025074532.GM18839@dhcp22.suse.cz>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-4-git-send-email-anshuman.khandual@arm.com>
 <20181024135639.GH18839@dhcp22.suse.cz>
 <20181024135859.GI18839@dhcp22.suse.cz>
 <bf5e636c-9cc4-50d6-4160-78a1a7703860@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf5e636c-9cc4-50d6-4160-78a1a7703860@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Thu 25-10-18 11:53:34, Anshuman Khandual wrote:
> 
> 
> On 10/24/2018 07:28 PM, Michal Hocko wrote:
> > On Wed 24-10-18 15:56:39, Michal Hocko wrote:
> >> On Tue 23-10-18 18:31:59, Anshuman Khandual wrote:
> >>> Architectures like arm64 have HugeTLB page sizes which are different than
> >>> generic sizes at PMD, PUD, PGD level and implemented via contiguous bits.
> >>> At present these special size HugeTLB pages cannot be identified through
> >>> macros like (PMD|PUD|PGDIR)_SHIFT and hence chosen not be migrated.
> >>>
> >>> Enabling migration support for these special HugeTLB page sizes along with
> >>> the generic ones (PMD|PUD|PGD) would require identifying all of them on a
> >>> given platform. A platform specific hook can precisely enumerate all huge
> >>> page sizes supported for migration. Instead of comparing against standard
> >>> huge page orders let hugetlb_migration_support() function call a platform
> >>> hook arch_hugetlb_migration_support(). Default definition for the platform
> >>> hook maintains existing semantics which checks standard huge page order.
> >>> But an architecture can choose to override the default and provide support
> >>> for a comprehensive set of huge page sizes.
> >>>
> >>> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> >>
> >> Acked-by: Michal Hocko <mhocko@use.com>
> > 
> > fat fingers here, should be mhocko@suse.com of course.
> 
> Sure no problems. As we had discussed earlier and agreed to keep the previous
> patch "mm/hugetlb: Enable PUD level huge page migration" separate and not fold
> into this one, I will assume your ACK on it as well unless your disagree.

OK with me.

-- 
Michal Hocko
SUSE Labs
