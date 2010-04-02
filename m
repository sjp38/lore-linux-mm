Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 76C356B020B
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 03:22:59 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1143572pzk.1
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 00:22:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <z2w5f4a33681004020000td60331aam2c6947954d78e46@mail.gmail.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
	 <20100402140406.d3d7f18e.kamezawa.hiroyu@jp.fujitsu.com>
	 <z2x28c262361004012215h2b2ea3dbu5260724f97f55b95@mail.gmail.com>
	 <z2w5f4a33681004020000td60331aam2c6947954d78e46@mail.gmail.com>
Date: Fri, 2 Apr 2010 16:22:56 +0900
Message-ID: <q2t28c262361004020022v8eda0491t61e510a1caa0ef@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: TAO HU <tghk48@motorola.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, TAO HU <taohu@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 2, 2010 at 4:00 PM, TAO HU <tghk48@motorola.com> wrote:
> Hi, kamezawa hiroyu
>
> Thanks for the hint!
>
> Hi, Minchan Kim
>
> Sorry. Not exactly sure your idea about <grep "page handling">.
> Below is a result of $ grep -n -r "list_del(&page->lru)" * in our src tre=
e

It's not enough.
Maybe you have to review your's patches based on mainline.

>
> arch/s390/mm/pgtable.c:83: =C2=A0 =C2=A0 =C2=A0list_del(&page->lru);
> arch/s390/mm/pgtable.c:226: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lis=
t_del(&page->lru);
> arch/x86/mm/pgtable.c:60: =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> drivers/xen/balloon.c:154: =C2=A0 =C2=A0 =C2=A0list_del(&page->lru);
> drivers/virtio/virtio_balloon.c:143: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0list_del(&page->lru);
> fs/cifs/file.c:1780: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&p=
age->lru);
> fs/btrfs/extent_io.c:2584: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0list_del(&page->lru);
> fs/mpage.c:388: =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> include/linux/mm_inline.h:37: =C2=A0 list_del(&page->lru);
> include/linux/mm_inline.h:47: =C2=A0 list_del(&page->lru);
> kernel/kexec.c:391: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&p=
age->lru);
> kernel/kexec.c:711: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/migrate.c:69: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0l=
ist_del(&page->lru);
> mm/migrate.c:695: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_d=
el(&page->lru);
> mm/hugetlb.c:467: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/hugetlb.c:509: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/hugetlb.c:836: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_d=
el(&page->lru);
> mm/hugetlb.c:844: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/hugetlb.c:900: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/hugetlb.c:1130: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0list_del(&page->lru);
> mm/hugetlb.c:1809: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_d=
el(&page->lru);
> mm/vmscan.c:597: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0l=
ist_del(&page->lru);
> mm/vmscan.c:1148: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/vmscan.c:1246: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_d=
el(&page->lru);
> mm/slub.c:827: =C2=A0list_del(&page->lru);
> mm/slub.c:1249: list_del(&page->lru);
> mm/slub.c:1263: =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/slub.c:2419: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 l=
ist_del(&page->lru);
> mm/slub.c:2809: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->lru);
> mm/readahead.c:65: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_d=
el(&page->lru);
> mm/readahead.c:100: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&p=
age->lru);
> mm/page_alloc.c:532: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&p=
age->lru);
> mm/page_alloc.c:679: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&p=
age->lru);
> mm/page_alloc.c:741: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&p=
age->lru);
> mm/page_alloc.c:820: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0list_del(&page->lru);
> mm/page_alloc.c:1107: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->=
lru);
> mm/page_alloc.c:4784: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&page->=
lru);
>
There are normal caller.
I expected some bogus driver of out-of-mainline uses page directly
without enough review.

Is your kernel working well except this bug?
Do you see same oops call trace(about page-allocator) whenever kernel
panic happens?

I mean if something not page-allocadtor breaks memory, you can see
other symptoms. so we can doubt others(H/W, other subsystem).

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
