Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18D096B0069
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:53:37 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so42673720wmw.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:53:37 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id l6si1517070wmd.112.2016.11.29.00.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 00:45:18 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id kp2so17151343wjc.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:45:18 -0800 (PST)
Date: Tue, 29 Nov 2016 09:45:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 04/12] mm: thp: introduce
 CONFIG_ARCH_ENABLE_THP_MIGRATION
Message-ID: <20161129084516.GB31671@dhcp22.suse.cz>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20161128142154.GM14788@dhcp22.suse.cz>
 <20161129075006.GA15582@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129075006.GA15582@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 29-11-16 07:50:06, Naoya Horiguchi wrote:
> On Mon, Nov 28, 2016 at 03:21:54PM +0100, Michal Hocko wrote:
> > On Tue 08-11-16 08:31:49, Naoya Horiguchi wrote:
> > > Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
> > > functionality to x86_64, which should be safer at the first step.
> > 
> > Please make sure to describe why this has to be arch specific and what
> > are arches supposed to provide in order to enable this option.
> 
> OK, the below will be added in the future version:
> 
>   Thp migration is an arch-specific feature because it depends on the
>   arch-dependent behavior of non-present format of page table entry.
>   What you need to enable this option in other archs are:
>   - to define arch-specific transformation functions like __pmd_to_swp_entry()
>     and __swp_entry_to_pmd(),
>   - to make sure that arch-specific page table walking code can properly handle
>     !pmd_present case (gup_pmd_range() is a good example),
>   - (if your archs enables CONFIG_HAVE_ARCH_SOFT_DIRTY,) to define soft dirty
>     routines like pmd_swp_mksoft_dirty.

Thanks this is _much_ better!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
