Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F93D6B0011
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:09:40 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s8so337287pgf.0
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:09:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y6-v6sor231976pln.151.2018.04.11.01.09.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 01:09:39 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 0/2] mm: migrate: vm event counter for hugepage migration
Date: Wed, 11 Apr 2018 17:09:25 +0900
Message-Id: <1523434167-19995-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Zi Yan <zi.yan@sent.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

Hi everyone,

I wrote patches introducing separate vm event counters for hugepage migration
(both for hugetlb and thp.)
Hugepage migration is different from normal page migration in event frequency
and/or how likely it succeeds, so maintaining statistics for them in mixed
counters might not be helpful both for develors and users.

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (2):
      mm: migrate: add vm event counters thp_migrate_(success|fail)
      mm: migrate: add vm event counters hugetlb_migrate_(success|fail)

 include/linux/vm_event_item.h |   7 +++
 mm/migrate.c                  | 103 +++++++++++++++++++++++++++++++++++-------
 mm/vmstat.c                   |   8 ++++
 3 files changed, 102 insertions(+), 16 deletions(-)
