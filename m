Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19A818E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 00:10:25 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q63so42420860pfi.19
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 21:10:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id az5sor35455810plb.11.2019.01.06.21.10.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 21:10:23 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
From: Fam Zheng <zhengfeiran@bytedance.com>
In-Reply-To: <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
Date: Mon, 7 Jan 2019 13:10:17 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
 <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Fam Zheng <zhengfeiran@bytedance.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com



> On Jan 5, 2019, at 03:36, Yang Shi <shy828301@gmail.com> wrote:
>=20
>=20
> drop_caches would drop all page caches globally. You may not want to
> drop the page caches used by other memcgs.

We=E2=80=99ve tried your async force_empty patch (with a modification to =
default it to true to make it transparently enabled for the sake of =
testing), and for the past few days the stale mem cgroups still =
accumulate, up to 40k.

We=E2=80=99ve double checked that the force_empty routines are invoked =
when a mem cgroup is offlined. But this doesn=E2=80=99t look very =
effective so far. Because, once we do `echo 1 > =
/proc/sys/vm/drop_caches`, all the groups immediately go away.

This is a bit unexpected.

Yang, could you hint what are missing in the force_empty operation, =
compared to a blanket drop cache?

Fam=
