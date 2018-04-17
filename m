Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D17956B0009
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 19:43:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j2so13558813qtl.1
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 16:43:19 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t188si2379012qkd.80.2018.04.17.16.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 16:43:19 -0700 (PDT)
Subject: Re: [PATCH v4 3/3] mm: restructure memfd code
References: <20180415182119.4517-1-mike.kravetz@oracle.com>
 <20180415182119.4517-4-mike.kravetz@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <3bcdcaba-3364-c633-2d9d-3df27c2a8f7c@oracle.com>
Date: Tue, 17 Apr 2018 17:42:57 -0600
MIME-Version: 1.0
In-Reply-To: <20180415182119.4517-4-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/15/2018 12:21 PM, Mike Kravetz wrote:
> With the addition of memfd hugetlbfs support, we now have the situation
> where memfd depends on TMPFS -or- HUGETLBFS.  Previously, memfd was only
> supported on tmpfs, so it made sense that the code resided in shmem.c.
> In the current code, memfd is only functional if TMPFS is defined.  If
> HUGETLFS is defined and TMPFS is not defined, then memfd functionality
> will not be available for hugetlbfs.  This does not cause BUGs, just a
> lack of potentially desired functionality.
> 
> Code is restructured in the following way:
> - include/linux/memfd.h is a new file containing memfd specific
>    definitions previously contained in shmem_fs.h.
> - mm/memfd.c is a new file containing memfd specific code previously
>    contained in shmem.c.
> - memfd specific code is removed from shmem_fs.h and shmem.c.
> - A new config option MEMFD_CREATE is added that is defined if TMPFS
>    or HUGETLBFS is defined.
> 
> No functional changes are made to the code: restructuring only.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>   fs/Kconfig               |   3 +
>   fs/fcntl.c               |   2 +-
>   include/linux/memfd.h    |  16 +++
>   include/linux/shmem_fs.h |  13 --
>   mm/Makefile              |   1 +
>   mm/memfd.c               | 345 +++++++++++++++++++++++++++++++++++++++++++++++
>   mm/shmem.c               | 324 --------------------------------------------
>   7 files changed, 366 insertions(+), 338 deletions(-)
>   create mode 100644 include/linux/memfd.h
>   create mode 100644 mm/memfd.c

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
