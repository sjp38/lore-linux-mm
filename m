Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 111D56B000A
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 09:59:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id v18-v6so2725959edq.23
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 06:59:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n24-v6si960106eja.12.2018.10.24.06.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 06:59:01 -0700 (PDT)
Date: Wed, 24 Oct 2018 15:58:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 3/5] mm/hugetlb: Enable arch specific huge page size
 support for migration
Message-ID: <20181024135859.GI18839@dhcp22.suse.cz>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-4-git-send-email-anshuman.khandual@arm.com>
 <20181024135639.GH18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024135639.GH18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Wed 24-10-18 15:56:39, Michal Hocko wrote:
> On Tue 23-10-18 18:31:59, Anshuman Khandual wrote:
> > Architectures like arm64 have HugeTLB page sizes which are different than
> > generic sizes at PMD, PUD, PGD level and implemented via contiguous bits.
> > At present these special size HugeTLB pages cannot be identified through
> > macros like (PMD|PUD|PGDIR)_SHIFT and hence chosen not be migrated.
> > 
> > Enabling migration support for these special HugeTLB page sizes along with
> > the generic ones (PMD|PUD|PGD) would require identifying all of them on a
> > given platform. A platform specific hook can precisely enumerate all huge
> > page sizes supported for migration. Instead of comparing against standard
> > huge page orders let hugetlb_migration_support() function call a platform
> > hook arch_hugetlb_migration_support(). Default definition for the platform
> > hook maintains existing semantics which checks standard huge page order.
> > But an architecture can choose to override the default and provide support
> > for a comprehensive set of huge page sizes.
> > 
> > Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> 
> Acked-by: Michal Hocko <mhocko@use.com>

fat fingers here, should be mhocko@suse.com of course.
-- 
Michal Hocko
SUSE Labs
