Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA616B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 05:28:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b128so6189230wme.0
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 02:28:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 90sor3560168wrp.84.2017.11.20.02.28.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 02:28:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171109014109.21077-1-mike.kravetz@oracle.com>
References: <20171109014109.21077-1-mike.kravetz@oracle.com>
From: =?UTF-8?B?TWFyYy1BbmRyw6kgTHVyZWF1?= <marcandre.lureau@gmail.com>
Date: Mon, 20 Nov 2017 11:28:09 +0100
Message-ID: <CAJ+F1CKsehGaan8ZgSNEBQ6sveyMVYH5Wr4ggys-czpmbV8Qvg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] restructure memfd code
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

Hi

On Thu, Nov 9, 2017 at 2:41 AM, Mike Kravetz <mike.kravetz@oracle.com> wrot=
e:
> With the addition of memfd hugetlbfs support, we now have the situation
> where memfd depends on TMPFS -or- HUGETLBFS.  Previously, memfd was only
> supported on tmpfs, so it made sense that the code resides in shmem.c.
>
> This patch series moves the memfd code to separate files (memfd.c and
> memfd.h).  It creates a new config option MEMFD_CREATE that is defined
> if either TMPFS or HUGETLBFS is defined.

That looks good to me

>
> In the current code, memfd is only functional if TMPFS is defined.  If
> HUGETLFS is defined and TMPFS is not defined, then memfd functionality
> will not be available for hugetlbfs.  This does not cause BUGs, just a
> potential lack of desired functionality.
>

Indeed

> Another way to approach this issue would be to simply make HUGETLBFS
> depend on TMPFS.
>
> This patch series is built on top of the Marc-Andr=C3=A9 Lureau v3 series
> "memfd: add sealing to hugetlb-backed memory":
> http://lkml.kernel.org/r/20171107122800.25517-1-marcandre.lureau@redhat.c=
om

Are you waiting for this series to be merged before resending as non-rfc?

>
> Mike Kravetz (3):
>   mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
>   mm: memfd: split out memfd for use by multiple filesystems
>   mm: memfd: remove memfd code from shmem files and use new memfd files
>
>  fs/Kconfig               |   3 +
>  fs/fcntl.c               |   2 +-
>  include/linux/hugetlb.h  |  27 ++--
>  include/linux/memfd.h    |  16 +++
>  include/linux/shmem_fs.h |  13 --
>  mm/Makefile              |   1 +
>  mm/memfd.c               | 341 +++++++++++++++++++++++++++++++++++++++++=
++++++
>  mm/shmem.c               | 323 -----------------------------------------=
---
>  8 files changed, 378 insertions(+), 348 deletions(-)
>  create mode 100644 include/linux/memfd.h
>  create mode 100644 mm/memfd.c
>
> --
> 2.13.6
>

Thanks

--=20
Marc-Andr=C3=A9 Lureau

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
