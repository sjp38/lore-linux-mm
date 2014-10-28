Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D9F64900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:11:11 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id q5so1721809wiv.5
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 07:11:11 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id m4si14591607wia.35.2014.10.28.07.11.09
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 07:11:09 -0700 (PDT)
Date: Tue, 28 Oct 2014 16:08:29 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/10] mm: improve usage of the i_mmap lock
Message-ID: <20141028140829.GA11524@node.dhcp.inet.fi>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On Fri, Oct 24, 2014 at 03:06:10PM -0700, Davidlohr Bueso wrote:
> Davidlohr Bueso (10):
>   mm,fs: introduce helpers around the i_mmap_mutex
>   mm: use new helper functions around the i_mmap_mutex
>   mm: convert i_mmap_mutex to rwsem
>   mm/rmap: share the i_mmap_rwsem
>   uprobes: share the i_mmap_rwsem
>   mm/xip: share the i_mmap_rwsem
>   mm/memory-failure: share the i_mmap_rwsem
>   mm/mremap: share the i_mmap_rwsem
>   mm/nommu: share the i_mmap_rwsem
>   mm/hugetlb: share the i_mmap_rwsem
> 
>  fs/hugetlbfs/inode.c         | 14 +++++++-------
>  fs/inode.c                   |  2 +-
>  include/linux/fs.h           | 23 ++++++++++++++++++++++-
>  include/linux/mmu_notifier.h |  2 +-
>  kernel/events/uprobes.c      |  6 +++---
>  kernel/fork.c                |  4 ++--
>  mm/filemap.c                 | 10 +++++-----
>  mm/filemap_xip.c             | 23 +++++++++--------------
>  mm/fremap.c                  |  4 ++--
>  mm/hugetlb.c                 | 22 +++++++++++-----------
>  mm/memory-failure.c          |  4 ++--
>  mm/memory.c                  |  8 ++++----
>  mm/mmap.c                    | 22 +++++++++++-----------
>  mm/mremap.c                  |  6 +++---
>  mm/nommu.c                   | 17 ++++++++---------
>  mm/rmap.c                    | 12 ++++++------
>  16 files changed, 97 insertions(+), 82 deletions(-)

Apart from already mentioned cosmetics, the patchset looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
