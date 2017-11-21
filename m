Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 21A626B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 11:32:26 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id o196so7844799vkf.4
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 08:32:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y130si3799716vkd.134.2017.11.21.08.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 08:32:24 -0800 (PST)
Message-ID: <1511281935.14446.3.camel@oracle.com>
Subject: Re: [RFC PATCH 0/3] restructure memfd code
From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Tue, 21 Nov 2017 09:32:15 -0700
In-Reply-To: <20171109014109.21077-1-mike.kravetz@oracle.com>
References: <20171109014109.21077-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?ISO-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2017-11-08 at 17:41 -0800, Mike Kravetz wrote:
> With the addition of memfd hugetlbfs support, we now have the
> situation
> where memfd depends on TMPFS -or- HUGETLBFS.=C2=A0=C2=A0Previously, memfd=
 was
> only
> supported on tmpfs, so it made sense that the code resides in
> shmem.c.
>=20
> This patch series moves the memfd code to separate files (memfd.c and
> memfd.h).=C2=A0=C2=A0It creates a new config option MEMFD_CREATE that is
> defined
> if either TMPFS or HUGETLBFS is defined.
>=20
> In the current code, memfd is only functional if TMPFS is
> defined.=C2=A0=C2=A0If
> HUGETLFS is defined and TMPFS is not defined, then memfd
> functionality
> will not be available for hugetlbfs.=C2=A0=C2=A0This does not cause BUGs,=
 just
> a
> potential lack of desired functionality.
>=20
> Another way to approach this issue would be to simply make HUGETLBFS
> depend on TMPFS.
>=20
> This patch series is built on top of the Marc-Andr=C3=A9 Lureau v3 series
> "memfd: add sealing to hugetlb-backed memory":
> http://lkml.kernel.org/r/20171107122800.25517-1-marcandre.lureau@redh
> at.com
>=20
> Mike Kravetz (3):
> =C2=A0 mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
> =C2=A0 mm: memfd: split out memfd for use by multiple filesystems
> =C2=A0 mm: memfd: remove memfd code from shmem files and use new memfd
> files
>=20

Hi Mike,

This looks like a useful change. After applying patch 2, you end up
with duplicate definitions of number of symbols though. Although those
duplicates will not cause compilation problems since memfd.c is not
compiled until after patch 3 has been applied, would it make more sense
to combine moving of all code in one patch?

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
