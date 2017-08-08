Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAEE6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 01:34:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x28so3170713wma.7
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 22:34:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si438773wrx.82.2017.08.07.22.34.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 22:34:01 -0700 (PDT)
Date: Tue, 8 Aug 2017 07:33:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/1] Add hugetlbfs support to memfd_create()
Message-ID: <20170808053357.GA27790@dhcp22.suse.cz>
References: <1502149672-7759-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502149672-7759-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,
I am one foot out of office and will be offline for two days so I
didn't get to review the patch yet but this information is an useful
information about the usecase that should be in the patch directly for
future reference.

On Mon 07-08-17 16:47:51, Mike Kravetz wrote:
> This patch came out of discussions in this e-mail thread [1].
> 
> The Oracle JVM team is developing a new garbage collection model.  This
> new model requires multiple mappings of the same anonymous memory.  One
> straight forward way to accomplish this is with memfd_create.  They can
> use the returned fd to create multiple mappings of the same memory.
> 
> The JVM today has an option to use (static hugetlb) huge pages.  If this
> option is specified, they would like to use the same garbage collection
> model requiring multiple mappings to the same memory.  Using hugetlbfs,
> it is possible to explicitly mount a filesystem and specify file paths
> in order to get an fd that can be used for multiple mappings.  However,
> this introduces additional system admin work and coordination.
> 
> Ideally they would like to get a hugetlbfs fd without requiring explicit
> mounting of a filesystem.   Today, mmap and shmget can make use of
> hugetlbfs without explicitly mounting a filesystem.  The patch adds this
> functionality to hugetlbfs.
> 
> A new flag MFD_HUGETLB is introduced to request a hugetlbfs file.  Like
> other system calls where hugetlb can be requested, the huge page size
> can be encoded in the flags argument is the non-default huge page size
> is desired.  hugetlbfs does not support sealing operations, therefore
> specifying MFD_ALLOW_SEALING with MFD_HUGETLB will result in EINVAL.
> 
> Of course, the memfd_man page would need updating if this type of
> functionality moves forward.
> 
> [1] https://lkml.org/lkml/2017/7/6/564
> 
> Mike Kravetz (1):
>   mm/shmem: add hugetlbfs support to memfd_create()
> 
>  include/uapi/linux/memfd.h | 24 ++++++++++++++++++++++++
>  mm/shmem.c                 | 37 +++++++++++++++++++++++++++++++------
>  2 files changed, 55 insertions(+), 6 deletions(-)
> 
> -- 
> 2.7.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
