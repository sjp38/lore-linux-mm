Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id DB7B76B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 07:00:08 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so142246246wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 04:00:08 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id i10si40326711wij.0.2015.08.20.04.00.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 04:00:07 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so142245585wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 04:00:07 -0700 (PDT)
Date: Thu, 20 Aug 2015 13:00:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150820110004.GB4632@dhcp22.suse.cz>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu 20-08-15 08:26:27, Naoya Horiguchi wrote:
> Currently there's no easy way to get per-process usage of hugetlb pages,

Is this really the case after your previous patch? You have both 
HugetlbPages and KernelPageSize which should be sufficient no?

Reading a single file is, of course, easier but is it really worth the
additional code? I haven't really looked at the patch so I might be
missing something but what would be an advantage over reading
/proc/<pid>/smaps and extracting the information from there?

[...]
>  Documentation/filesystems/proc.txt |  3 +++
>  fs/hugetlbfs/inode.c               | 12 ++++++++++
>  fs/proc/task_mmu.c                 |  1 +
>  include/linux/hugetlb.h            | 36 +++++++++++++++++++++++++++++
>  include/linux/mm_types.h           |  7 ++++++
>  kernel/fork.c                      |  3 +++
>  mm/hugetlb.c                       | 46 ++++++++++++++++++++++++++++++++++++++
>  mm/mmap.c                          |  1 +
>  mm/rmap.c                          |  4 +++-
>  9 files changed, 112 insertions(+), 1 deletion(-)
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
