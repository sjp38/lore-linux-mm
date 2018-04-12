Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 573376B0003
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 02:19:06 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t4-v6so3027411plo.9
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 23:19:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v31si402069pgn.4.2018.04.11.23.19.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 23:19:05 -0700 (PDT)
Date: Thu, 12 Apr 2018 08:18:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/2] mm: migrate: vm event counter for hugepage
 migration
Message-ID: <20180412061859.GR23400@dhcp22.suse.cz>
References: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@sent.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Wed 11-04-18 17:09:25, Naoya Horiguchi wrote:
> Hi everyone,
> 
> I wrote patches introducing separate vm event counters for hugepage migration
> (both for hugetlb and thp.)
> Hugepage migration is different from normal page migration in event frequency
> and/or how likely it succeeds, so maintaining statistics for them in mixed
> counters might not be helpful both for develors and users.

This is quite a lot of code to be added se we should better document
what it is intended for. Sure I understand your reasonaning about huge
pages are more likely to fail but is this really worth a separate
counter? Do you have an example of how this would be useful?

If we are there then what about different huge page sizes (for hugetlb)?
Do we need per-hstate stats?

In other words, is this really worth it?

>  include/linux/vm_event_item.h |   7 +++
>  mm/migrate.c                  | 103 +++++++++++++++++++++++++++++++++++-------
>  mm/vmstat.c                   |   8 ++++
>  3 files changed, 102 insertions(+), 16 deletions(-)

-- 
Michal Hocko
SUSE Labs
