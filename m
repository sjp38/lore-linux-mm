Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0B966B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 09:15:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id t92so13239122wrc.13
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 06:15:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m75sor1364396wmi.50.2017.12.20.06.15.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 06:15:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <aca9951c-7b8a-7884-5b31-c505e4e35d8a@oracle.com>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com> <aca9951c-7b8a-7884-5b31-c505e4e35d8a@oracle.com>
From: =?UTF-8?B?TWFyYy1BbmRyw6kgTHVyZWF1?= <marcandre.lureau@gmail.com>
Date: Wed, 20 Dec 2017 15:15:50 +0100
Message-ID: <CAJ+F1CJCbmUHSMfKou_LP3eMq+p-b7S9vbe1Vv=JsGMFr7bk_w@mail.gmail.com>
Subject: Re: [PATCH v3 0/9] memfd: add sealing to hugetlb-backed memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, David Herrmann <dh.herrmann@gmail.com>

Hi

On Wed, Nov 15, 2017 at 4:13 AM, Mike Kravetz <mike.kravetz@oracle.com> wro=
te:
> +Cc: Andrew, Michal, David
>
> Are there any other comments on this patch series from Marc-Andr=C3=A9?  =
Is anything
> else needed to move forward?
>
> I have reviewed the patches in the series.  David Herrmann (the original
> memfd_create/file sealing author) has also taken a look at the patches.
>
> One outstanding issue is sorting out the config option dependencies.  Alt=
hough,
> IMO this is not a strict requirement for this series.  I have addressed t=
his
> issue in a follow on series:
> http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.com

Are we good for the next merge window? Is Hugh Dickins the maintainer
with the final word, and doing the pull request? (sorry, I am not very
familiar with kernel development)

thanks!

>> Hi,
>>
>> Recently, Mike Kravetz added hugetlbfs support to memfd. However, he
>> didn't add sealing support. One of the reasons to use memfd is to have
>> shared memory sealing when doing IPC or sharing memory with another
>> process with some extra safety. qemu uses shared memory & hugetables
>> with vhost-user (used by dpdk), so it is reasonable to use memfd
>> now instead for convenience and security reasons.
>>
>> Thanks!
>>
>> v3:
>> - do remaining MFD_DEF_SIZE/mfd_def_size substitutions
>> - fix missing unistd.h include in common.c
>> - tweaked a bit commit message prefixes
>> - added reviewed-by tags
>>
>> v2:
>> - add "memfd-hugetlb:" prefix in memfd-test
>> - run fuse test on hugetlb backend memory
>> - rename function memfd_file_get_seals() -> memfd_file_seals_ptr()
>> - update commit messages
>> - added reviewed-by tags
>>
>> RFC->v1:
>> - split rfc patch, after early review feedback
>> - added patch for memfd-test changes
>> - fix build with hugetlbfs disabled
>> - small code and commit messages improvements
>>
>> Marc-Andr=C3=A9 Lureau (9):
>>   shmem: unexport shmem_add_seals()/shmem_get_seals()
>>   shmem: rename functions that are memfd-related
>>   hugetlb: expose hugetlbfs_inode_info in header
>>   hugetlb: implement memfd sealing
>>   shmem: add sealing support to hugetlb-backed memfd
>>   memfd-test: test hugetlbfs sealing
>>   memfd-test: add 'memfd-hugetlb:' prefix when testing hugetlbfs
>>   memfd-test: move common code to a shared unit
>>   memfd-test: run fuse test on hugetlb backend memory
>>
>>  fs/fcntl.c                                     |   2 +-
>>  fs/hugetlbfs/inode.c                           |  39 +++--
>>  include/linux/hugetlb.h                        |  11 ++
>>  include/linux/shmem_fs.h                       |   6 +-
>>  mm/shmem.c                                     |  59 ++++---
>>  tools/testing/selftests/memfd/Makefile         |   5 +
>>  tools/testing/selftests/memfd/common.c         |  46 ++++++
>>  tools/testing/selftests/memfd/common.h         |   9 ++
>>  tools/testing/selftests/memfd/fuse_test.c      |  44 +++--
>>  tools/testing/selftests/memfd/memfd_test.c     | 212 ++++--------------=
-------
>>  tools/testing/selftests/memfd/run_fuse_test.sh |   2 +-
>>  tools/testing/selftests/memfd/run_tests.sh     |   1 +
>>  12 files changed, 200 insertions(+), 236 deletions(-)
>>  create mode 100644 tools/testing/selftests/memfd/common.c
>>  create mode 100644 tools/testing/selftests/memfd/common.h
>>



--=20
Marc-Andr=C3=A9 Lureau

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
