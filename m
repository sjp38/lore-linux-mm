Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0511D6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 22:13:41 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id b13so14745807qtg.22
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 19:13:41 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d10si102371qkg.301.2017.11.14.19.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 19:13:39 -0800 (PST)
Subject: Re: [PATCH v3 0/9] memfd: add sealing to hugetlb-backed memory
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <aca9951c-7b8a-7884-5b31-c505e4e35d8a@oracle.com>
Date: Tue, 14 Nov 2017 19:13:25 -0800
MIME-Version: 1.0
In-Reply-To: <20171107122800.25517-1-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, David Herrmann <dh.herrmann@gmail.com>

+Cc: Andrew, Michal, David

Are there any other comments on this patch series from Marc-AndrA(C)?  Is anything
else needed to move forward?

I have reviewed the patches in the series.  David Herrmann (the original
memfd_create/file sealing author) has also taken a look at the patches.

One outstanding issue is sorting out the config option dependencies.  Although,
IMO this is not a strict requirement for this series.  I have addressed this
issue in a follow on series:
http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.com

-- 
Mike Kravetz


On 11/07/2017 04:27 AM, Marc-AndrA(C) Lureau wrote:
> Hi,
> 
> Recently, Mike Kravetz added hugetlbfs support to memfd. However, he
> didn't add sealing support. One of the reasons to use memfd is to have
> shared memory sealing when doing IPC or sharing memory with another
> process with some extra safety. qemu uses shared memory & hugetables
> with vhost-user (used by dpdk), so it is reasonable to use memfd
> now instead for convenience and security reasons.
> 
> Thanks!
> 
> v3:
> - do remaining MFD_DEF_SIZE/mfd_def_size substitutions
> - fix missing unistd.h include in common.c
> - tweaked a bit commit message prefixes
> - added reviewed-by tags
> 
> v2:
> - add "memfd-hugetlb:" prefix in memfd-test
> - run fuse test on hugetlb backend memory
> - rename function memfd_file_get_seals() -> memfd_file_seals_ptr()
> - update commit messages
> - added reviewed-by tags
> 
> RFC->v1:
> - split rfc patch, after early review feedback
> - added patch for memfd-test changes
> - fix build with hugetlbfs disabled
> - small code and commit messages improvements
> 
> Marc-AndrA(C) Lureau (9):
>   shmem: unexport shmem_add_seals()/shmem_get_seals()
>   shmem: rename functions that are memfd-related
>   hugetlb: expose hugetlbfs_inode_info in header
>   hugetlb: implement memfd sealing
>   shmem: add sealing support to hugetlb-backed memfd
>   memfd-test: test hugetlbfs sealing
>   memfd-test: add 'memfd-hugetlb:' prefix when testing hugetlbfs
>   memfd-test: move common code to a shared unit
>   memfd-test: run fuse test on hugetlb backend memory
> 
>  fs/fcntl.c                                     |   2 +-
>  fs/hugetlbfs/inode.c                           |  39 +++--
>  include/linux/hugetlb.h                        |  11 ++
>  include/linux/shmem_fs.h                       |   6 +-
>  mm/shmem.c                                     |  59 ++++---
>  tools/testing/selftests/memfd/Makefile         |   5 +
>  tools/testing/selftests/memfd/common.c         |  46 ++++++
>  tools/testing/selftests/memfd/common.h         |   9 ++
>  tools/testing/selftests/memfd/fuse_test.c      |  44 +++--
>  tools/testing/selftests/memfd/memfd_test.c     | 212 ++++---------------------
>  tools/testing/selftests/memfd/run_fuse_test.sh |   2 +-
>  tools/testing/selftests/memfd/run_tests.sh     |   1 +
>  12 files changed, 200 insertions(+), 236 deletions(-)
>  create mode 100644 tools/testing/selftests/memfd/common.c
>  create mode 100644 tools/testing/selftests/memfd/common.h
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
