Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id B9D37680DC6
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 00:53:32 -0400 (EDT)
Received: by qgez77 with SMTP id z77so125757862qge.1
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 21:53:32 -0700 (PDT)
Received: from BLU004-OMC1S9.hotmail.com (blu004-omc1s9.hotmail.com. [65.55.116.20])
        by mx.google.com with ESMTPS id 84si17701594qhx.86.2015.10.03.21.53.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Oct 2015 21:53:31 -0700 (PDT)
Message-ID: <BLU436-SMTP233624CAE8A4C054B5DFFF8B9490@phx.gbl>
Date: Sun, 4 Oct 2015 12:55:29 +0800
From: Chen Gang <xili_gchen_5257@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmap.c: Remove redundant vma looping
References: <COL130-W38E921DBAB9CFCFCC45F73B94A0@phx.gbl> <CAFLxGvyFeyV+kNoD5+4jzfid5dgkZP0uhhQ7Q7Dk-ObDJq4ByA@mail.gmail.com>
In-Reply-To: <CAFLxGvyFeyV+kNoD5+4jzfid5dgkZP0uhhQ7Q7Dk-ObDJq4ByA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "asha.levin@oracle.com" <asha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 10/4/15 04:09=2C Richard Weinberger wrote:
> With that change you're reintroducing an issue.
> Please see:
> commit 7cd5a02f54f4c9d16cf7fdffa2122bc73bb09b43
> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date:   Mon Aug 11 09:30:25 2008 +0200
>=20
>     mm: fix mm_take_all_locks() locking order
>=20
>     Lockdep spotted:
>=20
>     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
>     [ INFO: possible circular locking dependency detected ]
>     2.6.27-rc1 #270
>     -------------------------------------------------------
>     qemu-kvm/2033 is trying to acquire lock:
>      (&inode->i_data.i_mmap_lock){----}=2C at: [<ffffffff802996cc>]
> mm_take_all_locks+0xc2/0xea
>=20
>     but task is already holding lock:
>      (&anon_vma->lock){----}=2C at: [<ffffffff8029967a>]
> mm_take_all_locks+0x70/0xea
>=20
>     which lock already depends on the new lock.
>

Oh=2C really. Thanks.

>=20
> git blame often explains funky code. :-)
>=20

Next=2C I shall check the git log before make patches=2C each time. :-)

Theoretically=2C the lock and unlock need to be symmetric=2C if we have to
lock f_mapping all firstly=2C then lock all anon_vma=2C probably=2C we also
need to unlock anon_vma all=2C then unlock all f_mapping.


Thanks.
--=20
Chen Gang (=E9=99=88=E5=88=9A)

Open=2C share=2C and attitude like air=2C water=2C and life which God bless=
ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
