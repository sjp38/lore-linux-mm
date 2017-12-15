Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12DBE6B025E
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 04:33:13 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k104so4733975wrc.19
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 01:33:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si5013024wra.480.2017.12.15.01.33.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 01:33:11 -0800 (PST)
Date: Fri, 15 Dec 2017 10:33:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
Message-ID: <20171215093309.GU16951@dhcp22.suse.cz>
References: <20171204140117.7191-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171204140117.7191-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Naoya,
this has passed Mike's review (thanks for that!), you have mentioned
that you can pass this through your testing machinery earlier. While
I've done some testing already I would really appreciate if you could
do that as well. Review would be highly appreciated as well.

Thanks!

On Mon 04-12-17 15:01:12, Michal Hocko wrote:
> Hi,
> this is a follow up for [1] for the allocation API and [2] for the
> hugetlb migration. It wasn't really easy to split those into two
> separate patch series as they share some code.
> 
> My primary motivation to touch this code is to make the gigantic pages
> migration working. The giga pages allocation code is just too fragile
> and hacked into the hugetlb code now. This series tries to move giga
> pages closer to the first class citizen. We are not there yet but having
> 5 patches is quite a lot already and it will already make the code much
> easier to follow. I will come with other changes on top after this sees
> some review.
> 
> The first two patches should be trivial to review. The third patch
> changes the way how we migrate huge pages. Newly allocated pages are a
> subject of the overcommit check and they participate surplus accounting
> which is quite unfortunate as the changelog explains. This patch doesn't
> change anything wrt. giga pages.
> Patch #4 removes the surplus accounting hack from
> __alloc_surplus_huge_page.  I hope I didn't miss anything there and a
> deeper review is really due there.
> Patch #5 finally unifies allocation paths and giga pages shouldn't be
> any special anymore. There is also some renaming going on as well.
> 
> Shortlog
> Michal Hocko (5):
>       mm, hugetlb: unify core page allocation accounting and initialization
>       mm, hugetlb: integrate giga hugetlb more naturally to the allocation path
>       mm, hugetlb: do not rely on overcommit limit during migration
>       mm, hugetlb: get rid of surplus page accounting tricks
>       mm, hugetlb: further simplify hugetlb allocation API
> 
> Diffstat:
>  include/linux/hugetlb.h |   3 +
>  mm/hugetlb.c            | 305 +++++++++++++++++++++++++++---------------------
>  mm/migrate.c            |   3 +-
>  3 files changed, 175 insertions(+), 136 deletions(-)
> 
> 
> [1] http://lkml.kernel.org/r/20170622193034.28972-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20171122152832.iayefrlxbugphorp@dhcp22.suse.cz
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
