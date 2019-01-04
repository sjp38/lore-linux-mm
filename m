Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 398838E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 05:03:50 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l22so36829268pfb.2
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 02:03:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 27sor28533075pft.32.2019.01.04.02.03.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 02:03:49 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: memory cgroup pagecache and inode problem
From: Fam Zheng <zhengfeiran@bytedance.com>
In-Reply-To: <20190104090441.GI31793@dhcp22.suse.cz>
Date: Fri, 4 Jan 2019 18:02:19 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <E699E11E-32B9-4061-93BD-54FE52F972BA@bytedance.com>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <20190104090441.GI31793@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fam Zheng <zhengfeiran@bytedance.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>



> On Jan 4, 2019, at 17:04, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> This is a natural side effect of shared memory, I am afraid. Isolated
> memory cgroups should limit any shared resources to bare minimum. You
> will get "who touches first gets charged" behavior otherwise and that =
is
> not really deterministic.

I don=E2=80=99t quite understand your comment. I think the current =
behavior for the ext4_inode_cachep slab family is just =E2=80=9Cwho =
touches first gets charged=E2=80=9D, and later users of the same file =
from a different mem cgroup can benefit from the cache, keep it from =
being released, but doesn=E2=80=99t get charged.=
