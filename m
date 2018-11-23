Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 397BF6B3153
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 09:42:48 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w6so5957956otb.6
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:42:48 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q66si2900455oih.232.2018.11.23.06.42.47
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 06:42:47 -0800 (PST)
Date: Fri, 23 Nov 2018 14:42:42 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V3 5/5] arm64/mm: Enable HugeTLB migration for contiguous
 bit HugeTLB pages
Message-ID: <20181123144241.GE3360@arrakis.emea.arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-6-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540299721-26484-6-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, steve.capper@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, akpm@linux-foundation.org, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, suzuki.poulose@arm.com, mike.kravetz@oracle.com

On Tue, Oct 23, 2018 at 06:32:01PM +0530, Anshuman Khandual wrote:
> Let arm64 subscribe to the previously added framework in which architecture
> can inform whether a given huge page size is supported for migration. This
> just overrides the default function arch_hugetlb_migration_supported() and
> enables migration for all possible HugeTLB page sizes on arm64. With this,
> HugeTLB migration support on arm64 now covers all possible HugeTLB options.
> 
>         CONT PTE    PMD    CONT PMD    PUD
>         --------    ---    --------    ---
> 4K:        64K      2M        32M      1G
> 16K:        2M     32M         1G
> 64K:        2M    512M        16G
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
